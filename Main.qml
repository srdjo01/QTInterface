import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: qsTr("Homework - Circuit Editor")
    color: "#1e1e1e"

    property string projectPath: ""

    function resetSession() {
        projectPath = ""
        centralWorkspace.clearWorkspace()
        rightPanel.clearSelection()
        bottomLog.clear()
        root.title = qsTr("Homework - Circuit Editor")
    }

    FolderDialog {
        id: newProjectFolderDialog
        title: qsTr("Select folder for new project")
        onAccepted: {
            root.resetSession()
            root.projectPath = selectedFolder
            root.title = qsTr("Homework - Circuit Editor") + " — " + selectedFolder
            bottomLog.log("New project created")
        }
    }

    header: MainToolbar {
        id: toolbar
        onNewProject: {
            newProjectFolderDialog.open()
        }
        onSaveProject: {
            saveDialog.open()
        }
        onLoadProject: {
            loadDialog.open()
        }
        onResetView: {
            centralWorkspace.resetView()
        }
        onToggleGrid: {
            centralWorkspace.toggleGrid()
        }
        onRunCheck: {
            bottomLog.log("Run check started")
            centralWorkspace.validate()
        }
    }

    // -- Gather workspace state as JSON --
    function gatherProjectJson() {
        var elements = []
        for (var i = 0; i < centralWorkspace.placedItems.count; i++) {
            var item = centralWorkspace.placedItems.get(i)
            elements.push({
                name: item.name,
                label: item.label,
                posX: item.posX,
                posY: item.posY,
                connectedTo: item.connectedTo,
                vrednost: item.vrednost,
                status: item.status
            })
        }
        var data = {
            projectPath: root.projectPath,
            grid: centralWorkspace.showGrid,
            zoom: centralWorkspace.zoomLevel,
            panX: centralWorkspace.panX,
            panY: centralWorkspace.panY,
            selectedElement: rightPanel.selectedElement,
            elements: elements
        }
        return JSON.stringify(data, null, 2)
    }

    function applyProjectJson(json) {
        var data = JSON.parse(json)
        root.projectPath = data.projectPath || ""
        centralWorkspace.showGrid = data.grid !== undefined ? data.grid : true
        centralWorkspace.zoomLevel = data.zoom || 1.0
        centralWorkspace.panX = data.panX || 0
        centralWorkspace.panY = data.panY || 0
        if (data.elements) {
            for (var i = 0; i < data.elements.length; i++) {
                var el = data.elements[i]
                centralWorkspace.placedItems.append({
                    name: el.name,
                    label: el.label,
                    posX: el.posX,
                    posY: el.posY,
                    connectedTo: el.connectedTo || "",
                    vrednost: el.vrednost || 0,
                    status: el.status || "Aktivno"
                })
            }
        }
        if (data.selectedElement)
            rightPanel.showElement(data.selectedElement)
        root.title = qsTr("Homework - Circuit Editor") + (root.projectPath !== "" ? (" — " + root.projectPath) : "")
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save Project")
        fileMode: FileDialog.SaveFile
        nameFilters: ["Project files (*.json)"]
        onAccepted: {
            var json = root.gatherProjectJson()
            var ok = ProjectManager.saveToFile(selectedFile, json)
            if (ok)
                bottomLog.log("Project saved")
            else
                bottomLog.log("ERROR: Failed to save project")
        }
    }

    FileDialog {
        id: loadDialog
        title: qsTr("Load Project")
        fileMode: FileDialog.OpenFile
        nameFilters: ["Project files (*.json)"]
        onAccepted: {
            var json = ProjectManager.loadFromFile(selectedFile)
            if (json !== "") {
                root.resetSession()
                root.applyProjectJson(json)
                bottomLog.log("Project loaded from: " + selectedFile)
            } else {
                bottomLog.log("ERROR: Failed to load project")
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        LeftPanel {
            id: leftPanel
            Layout.fillHeight: true
            onElementSelected: function(name, index) {
                rightPanel.showElement(name)
                bottomLog.log("Element selected: " + name)
            }
            onElementInsert: function(name) {
                var cx = centralWorkspace.width / 2 / centralWorkspace.zoomLevel - 40
                var cy = centralWorkspace.height / 2 / centralWorkspace.zoomLevel - 30
                centralWorkspace.addItem(name, cx, cy)
            }
        }

        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#555555"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            CentralWorkspace {
                id: centralWorkspace
                Layout.fillWidth: true
                Layout.fillHeight: true
                onLogMessage: function(msg) {
                    bottomLog.log(msg)
                }
                onElementClicked: function(name, idx) {
                    rightPanel.showElementFromWorkspace(name, idx, centralWorkspace.placedItems)
                    bottomLog.log("Element selected: " + name)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#555555"
            }

            BottomPanel {
                id: bottomLog
                Layout.fillWidth: true
            }
        }

        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#555555"
        }

        RightPanel {
            id: rightPanel
            Layout.fillHeight: true
            onParameterChanged: function(key, value) {
                bottomLog.log(value)
            }
        }
    }

    Component.onCompleted: {
        bottomLog.log("Application started")
        bottomLog.log("Ready")
    }
}
