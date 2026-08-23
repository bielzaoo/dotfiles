import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../../"
import "../../components"

Item {
    id: root
    implicitWidth: icon.implicitWidth + 16
    implicitHeight: parent.height

    property bool expanded: false
    property var barWindow: null

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btEnabled: adapter ? adapter.enabled : false

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.btEnabled ? "\uf293" : "\uf294"
        color: root.expanded ? Colors.accent : Colors.textPrimary
        font.pixelSize: 14
        font.family: Fonts.family

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    PopupWindow {
        id: popup
        visible: root.expanded
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow ? root.barWindow.width - implicitWidth - 12 : 0
        anchor.rect.y: root.barWindow ? root.barWindow.height : 0
        implicitWidth: 200
        implicitHeight: contentColumn.implicitHeight + 16
        color: Colors.backgroundAlt

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Colors.accentDim
            border.width: 1
            radius: 6

            Column {
                id: contentColumn
                anchors.centerIn: parent
                spacing: 4
                width: parent.width - 16

                // Toggle liga/desliga
                Rectangle {
                    width: parent.width
                    height: 30
                    radius: 4
                    color: powerToggleArea.containsMouse ? Colors.accentDim : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Text {
                            text: root.btEnabled ? "Desligar Bluetooth" : "Ligar Bluetooth"
                            color: Colors.textPrimary
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: powerToggleArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerProc.command = ["bluetoothctl", "power", root.btEnabled ? "off" : "on"]
                            powerProc.running = true
                        }
                    }
                }

                // Separador
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.accentDim
                    visible: root.btEnabled
                }

                // Lista de dispositivos (só mostra se o adaptador estiver ligado)
                Repeater {
                    model: (root.btEnabled && root.adapter) ? root.adapter.devices : []

                    delegate: Rectangle {
                        id: deviceRow
                        required property var modelData

                        visible: modelData.paired
                        width: parent.width
                        height: modelData.paired ? 30 : 0
                        radius: 4
                        color: mouseArea.containsMouse ? Colors.accentDim : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: deviceRow.modelData.connected ? Colors.success : Colors.textMuted
                            }

                            Text {
                                text: deviceRow.modelData.name
                                color: Colors.textPrimary
                                font.pixelSize: 12
                                width: parent.width - 20
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: deviceRow.modelData.connected = !deviceRow.modelData.connected
                        }
                    }
                }

                Text {
                    text: "Nenhum dispositivo pareado"
                    color: Colors.textMuted
                    font.pixelSize: 11
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.btEnabled && root.adapter && root.adapter.devices.values.filter(d => d.paired).length === 0
                }
            }
        }

        Process {
            id: powerProc
        }
    }
}
