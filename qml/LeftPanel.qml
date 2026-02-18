import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: leftPanel
    color: "#2b2b2b"
    width: 200

    signal elementSelected(string name, int index)
    signal elementInsert(string name)

    property alias model: elementList.model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Label {
            text: qsTr("Elements")
            font.bold: true
            font.pixelSize: 14
            color: "#ffffff"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            padding: 6
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#555555"
        }

        ListView {
            id: elementList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: ListModel {
                ListElement { name: "Čvor"; category: "Struktura" }
                ListElement { name: "Veza"; category: "Struktura" }
                ListElement { name: "Ulaz"; category: "Interfejs" }
                ListElement { name: "Izlaz"; category: "Interfejs" }
                ListElement { name: "Funkcija"; category: "Logika" }
            }

            delegate: Item {
                id: delegateRoot
                width: elementList.width
                height: 36

                property string elName: model.name

                Rectangle {
                    id: delegateRect
                    width: parent.width
                    height: parent.height
                    radius: 4
                    color: delegateMouseArea.containsMouse ? "#444444" : (elementList.currentIndex === index ? "#3a6ea5" : "transparent")

                    Drag.active: delegateMouseArea.drag.active
                    Drag.mimeData: { "text/element": model.name }
                    Drag.dragType: Drag.Automatic
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Canvas {
                            width: 20
                            height: 20
                            property string elName: delegateRoot.elName
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "#90caf9"
                                ctx.fillStyle = "#90caf9"
                                ctx.lineWidth = 1.5

                                if (elName === "Čvor") {
                                    ctx.beginPath()
                                    ctx.arc(10, 10, 7, 0, 2 * Math.PI)
                                    ctx.fill()
                                } else if (elName === "Veza") {
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
                                } else if (elName === "Ulaz") {
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
                                } else if (elName === "Izlaz") {
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
                                } else if (elName === "Funkcija") {
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
                            text: model.name
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                        }
                        Label {
                            text: model.category
                            color: "#888888"
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        drag.target: delegateRect
                        onClicked: {
                            elementList.currentIndex = index
                            leftPanel.elementSelected(model.name, index)
                        }
                        onDoubleClicked: {
                            leftPanel.elementInsert(model.name)
                        }
                        onReleased: {
                            delegateRect.x = 0
                            delegateRect.y = 0
                        }
                    }
                }
            }
        }
    }
}
