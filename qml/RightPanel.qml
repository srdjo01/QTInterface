import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rightPanel
    color: "#2b2b2b"
    width: 220

    property string selectedElement: ""
    property int selectedModelIndex: -1
    property var workspaceModel: null

    signal parameterChanged(string key, string value)

    function showElement(name) {
        selectedElement = name
        selectedModelIndex = -1
        workspaceModel = null
        if (name !== "") {
            nazivField.text = name
            tipField.text = name
            vrednostSpin.value = 0
            statusCombo.currentIndex = 0
        } else {
            clearSelection()
        }
    }

    function showElementFromWorkspace(name, idx, model) {
        selectedElement = name
        selectedModelIndex = idx
        workspaceModel = model

        if (idx >= 0 && model) {
            var item = model.get(idx)
            nazivField.text = item.label
            tipField.text = item.name
            vrednostSpin.value = item.vrednost
            statusCombo.currentIndex = item.status === "Neaktivno" ? 1 : 0
        }
    }

    function clearSelection() {
        selectedElement = ""
        selectedModelIndex = -1
        workspaceModel = null
        nazivField.text = ""
        tipField.text = ""
        vrednostSpin.value = 0
        statusCombo.currentIndex = 0
    }

    function _updateModel(key, value) {
        if (selectedModelIndex >= 0 && workspaceModel) {
            var label = workspaceModel.get(selectedModelIndex).label
            parameterChanged(key, value)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Label {
            text: qsTr("Parameters")
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

        Label {
            id: headerLabel
            text: selectedElement !== "" ? selectedElement : qsTr("Nijedan element nije selektovan")
            color: selectedElement !== "" ? "#90caf9" : "#888888"
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            padding: 4
        }

        // --- Properties form ---
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: formColumn.height
            clip: true
            enabled: selectedElement !== ""
            opacity: selectedElement !== "" ? 1.0 : 0.4

            ColumnLayout {
                id: formColumn
                width: parent.width
                spacing: 12

                // Naziv
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: qsTr("Naziv")
                        color: "#aaaaaa"
                        font.pixelSize: 11
                        Layout.leftMargin: 8
                    }
                    TextField {
                        id: nazivField
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: "#e0e0e0"
                        placeholderText: "Element name"
                        background: Rectangle {
                            color: "#3c3c3c"
                            radius: 3
                            border.color: parent.activeFocus ? "#3a6ea5" : "#555555"
                        }
                        onEditingFinished: {
                            if (rightPanel.selectedModelIndex >= 0 && rightPanel.workspaceModel) {
                                rightPanel.workspaceModel.setProperty(rightPanel.selectedModelIndex, "label", text)
                                var label = text
                                rightPanel.parameterChanged("Naziv", "Element " + label + " updated")
                            }
                        }
                    }
                }

                // Tip (read-only)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: qsTr("Tip")
                        color: "#aaaaaa"
                        font.pixelSize: 11
                        Layout.leftMargin: 8
                    }
                    TextField {
                        id: tipField
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: "#999999"
                        readOnly: true
                        background: Rectangle {
                            color: "#333333"
                            radius: 3
                            border.color: "#444444"
                        }
                    }
                }

                // Vrednost
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: qsTr("Vrednost")
                        color: "#aaaaaa"
                        font.pixelSize: 11
                        Layout.leftMargin: 8
                    }
                    SpinBox {
                        id: vrednostSpin
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        from: 0
                        to: 1000
                        value: 0
                        editable: true
                        onValueModified: {
                            if (rightPanel.selectedModelIndex >= 0 && rightPanel.workspaceModel) {
                                rightPanel.workspaceModel.setProperty(rightPanel.selectedModelIndex, "vrednost", value)
                                var label = rightPanel.workspaceModel.get(rightPanel.selectedModelIndex).label
                                rightPanel.parameterChanged("Vrednost", "Element " + label + " updated")
                            }
                        }
                    }
                }

                // Status
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Label {
                        text: qsTr("Status")
                        color: "#aaaaaa"
                        font.pixelSize: 11
                        Layout.leftMargin: 8
                    }
                    ComboBox {
                        id: statusCombo
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        model: ["Aktivno", "Neaktivno"]
                        onActivated: {
                            if (rightPanel.selectedModelIndex >= 0 && rightPanel.workspaceModel) {
                                rightPanel.workspaceModel.setProperty(rightPanel.selectedModelIndex, "status", currentText)
                                var label = rightPanel.workspaceModel.get(rightPanel.selectedModelIndex).label
                                rightPanel.parameterChanged("Status", "Element " + label + " updated")
                            }
                        }
                    }
                }
            }
        }
    }
}
