import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "modules/bar"
import "modules/notifications"
import "modules/osd"

ShellRoot {
    PanelWindow {
        id: bar
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 32
        color: Colors.background

        Workspaces {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        Clock {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            SystemStats {}
            BluetoothPanel {
                anchors.verticalCenter: parent.verticalCenter
                barWindow: bar
            }
            PowerMenu {
                anchors.verticalCenter: parent.verticalCenter
                barWindow: bar
            }
        }
    }

    NotificationPopup {}

    VolumeOSD {
        id: volumeOsd
    }

    BrightnessOSD {
        id: brightnessOsd
    }

    IpcHandler {
        target: "osd"

        function volumeUp() {
            volumeOsd.nudge(0.05)
        }
        function volumeDown() {
            volumeOsd.nudge(-0.05)
        }
        function volumeMuteToggle() {
            volumeOsd.toggleMute()
        }
        function brightnessUp() {
            brightnessOsd.nudge(5)
        }
        function brightnessDown() {
            brightnessOsd.nudge(-5)
        }
    }
}
