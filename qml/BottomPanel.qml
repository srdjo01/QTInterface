import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bottomPanel
    color: "#1e1e1e"
    height: 150

    function log(message) {
        var timestamp = new Date().toLocaleTimeString()
        logModel.append({ text: "[" + timestamp + "] " + message })
        logView.positionViewAtEnd()
    }

    function clear() {
        logModel.clear()
    }

    ListModel {
        id: logModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: "#2b2b2b"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Label {
                    text: qsTr("Event Log")
                    font.bold: true
                    font.pixelSize: 12
                    color: "#ffffff"
                    Layout.fillWidth: true
                }
                ToolButton {
                    text: qsTr("Clear")
                    font.pixelSize: 10
                    onClicked: bottomPanel.clear()
                }
            }
        }

        ListView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: logModel

            delegate: Label {
                text: model.text
                color: "#cccccc"
                font.family: "Consolas"
                font.pixelSize: 11
                padding: 2
                leftPadding: 8
                width: logView.width
                wrapMode: Text.Wrap
            }
        }
    }
}
