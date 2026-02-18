import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: mainToolbar

    signal newProject()
    signal saveProject()
    signal loadProject()
    signal resetView()
    signal toggleGrid()
    signal runCheck()

    RowLayout {
        anchors.fill: parent
        spacing: 4

        ToolButton {
            text: qsTr("New Project")
            icon.name: "document-new"
            onClicked: mainToolbar.newProject()
        }
        ToolButton {
            text: qsTr("Save Project")
            icon.name: "document-save"
            onClicked: mainToolbar.saveProject()
        }
        ToolButton {
            text: qsTr("Load Project")
            icon.name: "document-open"
            onClicked: mainToolbar.loadProject()
        }

        ToolSeparator {}

        ToolButton {
            text: qsTr("Reset View")
            icon.name: "view-refresh"
            onClicked: mainToolbar.resetView()
        }
        ToolButton {
            text: qsTr("Toggle Grid")
            icon.name: "view-grid"
            checkable: true
            onClicked: mainToolbar.toggleGrid()
        }

        ToolSeparator {}

        ToolButton {
            text: qsTr("Run Check")
            icon.name: "dialog-ok-apply"
            onClicked: mainToolbar.runCheck()
        }

        Item { Layout.fillWidth: true }
    }
}
