import QtQuick
import QtQuick.Controls

Rectangle {
    id: workspace
    color: "#1a1a2e"
    clip: true

    property bool showGrid: true
    property real zoomLevel: 1.0
    property real panX: 0
    property real panY: 0
    property int selectedIndex: -1

    signal itemPlaced(string name, real x, real y)
    signal logMessage(string message)
    signal elementClicked(string name, int index)

    property alias placedItems: placedItemsModel

    ListModel {
        id: placedItemsModel
    }

    // Auto-increment counters for naming
    property var nameCounters: ({})

    function addItem(name, x, y) {
        if (!nameCounters[name])
            nameCounters[name] = 0
        nameCounters[name]++
        var label = name + "_" + nameCounters[name]
        placedItemsModel.append({
            name: name,
            label: label,
            posX: x,
            posY: y,
            connectedTo: "",
            vrednost: 0,
            status: "Aktivno"
        })
        selectedIndex = placedItemsModel.count - 1
        itemPlaced(name, x, y)
        logMessage("Element added: " + name + " at (" + Math.round(x) + ", " + Math.round(y) + ")")
        elementClicked(name, selectedIndex)
    }

    function clearWorkspace() {
        placedItemsModel.clear()
        nameCounters = {}
        selectedIndex = -1
        resetView()
        logMessage("Workspace cleared")
    }

    function validate() {
        logMessage("--- Running network validation ---")
        var count = placedItemsModel.count
        if (count === 0) {
            logMessage("Warning: workspace is empty, nothing to validate")
            logMessage("Validation finished – FAIL")
            return false
        }

        var warnings = []
        var hasInput = false
        var hasOutput = false
        var hasCvor = false
        var hasVeza = false
        var hasFunkcija = false

        for (var i = 0; i < count; i++) {
            var item = placedItemsModel.get(i)
            if (item.name === "Ulaz") hasInput = true
            if (item.name === "Izlaz") hasOutput = true
            if (item.name === "Čvor") hasCvor = true
            if (item.name === "Veza") hasVeza = true
            if (item.name === "Funkcija") hasFunkcija = true
        }

        logMessage("Found " + count + " element(s)")

        if (!hasInput)
            warnings.push("Warning: no 'Ulaz' element found – network has no input")
        if (!hasOutput)
            warnings.push("Warning: no 'Izlaz' element found – network has no output")
        if (!hasVeza && count > 1)
            warnings.push("Warning: no 'Veza' element found – elements are unconnected")
        if (hasCvor && !hasVeza)
            warnings.push("Warning: unconnected node – 'Čvor' exists but no 'Veza'")
        if (hasFunkcija && !hasInput)
            warnings.push("Warning: 'Funkcija' has no input source")

        var cvorCount = 0
        var vezaCount = 0
        for (var j = 0; j < count; j++) {
            var el = placedItemsModel.get(j)
            if (el.name === "Čvor") cvorCount++
            if (el.name === "Veza") vezaCount++
        }
        if (cvorCount > 0 && vezaCount < cvorCount - 1)
            warnings.push("Warning: not enough connections – " + cvorCount + " node(s) but only " + vezaCount + " link(s)")

        if (warnings.length === 0) {
            logMessage("Validation finished – OK")
            return true
        } else {
            for (var w = 0; w < warnings.length; w++)
                logMessage(warnings[w])
            logMessage("Validation finished – " + warnings.length + " warning(s)")
            return false
        }
    }

    function resetView() {
        zoomLevel = 1.0
        panX = 0
        panY = 0
        logMessage("View reset to default")
    }

    function toggleGrid() {
        showGrid = !showGrid
        logMessage("Grid " + (showGrid ? "enabled" : "disabled"))
    }

    // --- Grid layer ---
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        visible: workspace.showGrid

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "#2a2a4a"
            ctx.lineWidth = 0.5

            var step = 20 * workspace.zoomLevel
            var offsetX = workspace.panX % step
            var offsetY = workspace.panY % step

            for (var x = offsetX; x < width; x += step) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }
            for (var y = offsetY; y < height; y += step) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }
    }

    Connections {
        target: workspace
        function onShowGridChanged() { gridCanvas.requestPaint() }
        function onZoomLevelChanged() { gridCanvas.requestPaint() }
        function onPanXChanged() { gridCanvas.requestPaint() }
        function onPanYChanged() { gridCanvas.requestPaint() }
        function onWidthChanged() { gridCanvas.requestPaint() }
        function onHeightChanged() { gridCanvas.requestPaint() }
    }

    // --- Background mouse area for pan + zoom + deselect ---
    MouseArea {
        id: bgMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        property real lastX: 0
        property real lastY: 0
        property bool panning: false

        onPressed: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                panning = true
                lastX = mouse.x
                lastY = mouse.y
            } else if (mouse.button === Qt.LeftButton) {
                workspace.selectedIndex = -1
            }
        }
        onReleased: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                panning = false
            }
        }
        onPositionChanged: function(mouse) {
            if (panning) {
                workspace.panX += mouse.x - lastX
                workspace.panY += mouse.y - lastY
                lastX = mouse.x
                lastY = mouse.y
            }
        }
        onWheel: function(wheel) {
            var factor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
            workspace.zoomLevel = Math.max(0.2, Math.min(5.0, workspace.zoomLevel * factor))
        }
    }

    // --- Elements container (pan + zoom transform) ---
    Item {
        id: elementsContainer
        x: workspace.panX
        y: workspace.panY
        scale: workspace.zoomLevel
        transformOrigin: Item.TopLeft

        Repeater {
            model: placedItemsModel

            delegate: Rectangle {
                id: elementItem
                x: model.posX
                y: model.posY
                width: 80
                height: 60
                radius: 6
                color: workspace.selectedIndex === index ? "#2a4a6a" : "#252545"
                border.color: workspace.selectedIndex === index ? "#5599dd" : "#3a3a5a"
                border.width: workspace.selectedIndex === index ? 2 : 1

                property string elName: model.name

                Canvas {
                    id: elemCanvas
                    width: 20
                    height: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 6

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#90caf9"
                        ctx.fillStyle = "#90caf9"
                        ctx.lineWidth = 1.5

                        if (elementItem.elName === "Čvor") {
                            ctx.beginPath()
                            ctx.arc(10, 10, 7, 0, 2 * Math.PI)
                            ctx.fill()
                        } else if (elementItem.elName === "Veza") {
                            ctx.beginPath()
                            ctx.arc(4, 10, 3, 0, 2 * Math.PI)
                            ctx.fill()
                            ctx.beginPath()
                            ctx.arc(16, 10, 3, 0, 2 * Math.PI)
                            ctx.fill()
                            ctx.beginPath()
                            ctx.moveTo(7, 10)
                            ctx.lineTo(13, 10)
                            ctx.stroke()
                        } else if (elementItem.elName === "Ulaz") {
                            ctx.beginPath()
                            ctx.moveTo(3, 10)
                            ctx.lineTo(13, 10)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(13, 10)
                            ctx.lineTo(9, 6)
                            ctx.moveTo(13, 10)
                            ctx.lineTo(9, 14)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(3, 5)
                            ctx.lineTo(3, 15)
                            ctx.stroke()
                        } else if (elementItem.elName === "Izlaz") {
                            ctx.beginPath()
                            ctx.moveTo(17, 10)
                            ctx.lineTo(7, 10)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(7, 10)
                            ctx.lineTo(11, 6)
                            ctx.moveTo(7, 10)
                            ctx.lineTo(11, 14)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(17, 5)
                            ctx.lineTo(17, 15)
                            ctx.stroke()
                        } else if (elementItem.elName === "Funkcija") {
                            ctx.beginPath()
                            ctx.arc(10, 10, 4, 0, 2 * Math.PI)
                            ctx.stroke()
                            var spokes = 6
                            for (var i = 0; i < spokes; i++) {
                                var angle = (i / spokes) * 2 * Math.PI
                                ctx.beginPath()
                                ctx.moveTo(10 + 5 * Math.cos(angle), 10 + 5 * Math.sin(angle))
                                ctx.lineTo(10 + 8 * Math.cos(angle), 10 + 8 * Math.sin(angle))
                                ctx.stroke()
                            }
                        }
                    }
                }

                Label {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: model.label
                    color: "#cccccc"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: elementItem
                    onClicked: {
                        workspace.selectedIndex = index
                        workspace.elementClicked(model.name, index)
                    }
                    onReleased: {
                        if (drag.active) {
                            placedItemsModel.setProperty(index, "posX", elementItem.x)
                            placedItemsModel.setProperty(index, "posY", elementItem.y)
                        }
                    }
                }
            }
        }
    }

    // --- Drop area for receiving elements from left panel ---
    DropArea {
        id: dropArea
        anchors.fill: parent
        keys: ["text/element"]

        onDropped: function(drop) {
            var localX = (drop.x - workspace.panX) / workspace.zoomLevel - 40
            var localY = (drop.y - workspace.panY) / workspace.zoomLevel - 30
            var name = drop.getDataAsString("text/element")
            if (name !== "")
                workspace.addItem(name, localX, localY)
        }
    }

    // --- Placeholder label ---
    Label {
        anchors.centerIn: parent
        text: qsTr("Workspace - Drag elements here")
        color: "#555555"
        font.pixelSize: 16
        visible: placedItemsModel.count === 0
    }
}
