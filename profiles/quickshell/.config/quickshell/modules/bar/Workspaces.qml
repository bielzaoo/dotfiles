import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../"

Row {
    id: root
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: wsIndicator
            required property var modelData

            width: 24
            height: 20
            radius: 4
            color: modelData.active ? Colors.accent : Colors.backgroundAlt
            border.color: Colors.accentDim
            border.width: modelData.active ? 0 : 1

            Text {
                anchors.centerIn: parent
                text: wsIndicator.modelData.id
                color: wsIndicator.modelData.active ? Colors.background : Colors.textMuted
                font.pixelSize: 11
                font.bold: wsIndicator.modelData.active
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    dispatchProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({workspace=\"" + wsIndicator.modelData.id + "\"})"]
                    dispatchProc.running = true
                }
            }
        }
    }

    Process {
        id: dispatchProc
    }
}
