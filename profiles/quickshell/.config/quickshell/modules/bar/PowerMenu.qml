import QtQuick
import Quickshell
import Quickshell.Io
import "../../"
import "../../components"

Item {
    id: root
    implicitWidth: icon.implicitWidth + 16
    implicitHeight: parent.height

    property bool expanded: false
    property var barWindow: null

    Text {
        id: icon
        anchors.centerIn: parent
        text: "⏻"
        color: root.expanded ? Colors.accent : Colors.textPrimary
        font.pixelSize: 15
        font.bold: true

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
        implicitWidth: 140
        implicitHeight: menuColumn.implicitHeight + 16
        color: Colors.backgroundAlt

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Colors.accentDim
            border.width: 1
            radius: 6

            Column {
                id: menuColumn
                anchors.centerIn: parent
                spacing: 4
                width: parent.width - 16

                PowerMenuItem {
                    label: "Lock"
                    onClicked: {
                        actionProc.command = ["hyprlock"]
                        actionProc.running = true
                        root.expanded = false
                    }
                }
                PowerMenuItem {
                    label: "Logout"
                    onClicked: {
                        actionProc.command = ["hyprctl", "dispatch", "hl.dsp.exit()"]
                        actionProc.running = true
                        root.expanded = false
                    }
                }
                PowerMenuItem {
                    label: "Reboot"
                    isDanger: true
                    onClicked: {
                        actionProc.command = ["systemctl", "reboot"]
                        actionProc.running = true
                        root.expanded = false
                    }
                }
                PowerMenuItem {
                    label: "Shutdown"
                    isDanger: true
                    onClicked: {
                        actionProc.command = ["systemctl", "poweroff"]
                        actionProc.running = true
                        root.expanded = false
                    }
                }
            }
        }
    }

    Process {
        id: actionProc
    }
}
