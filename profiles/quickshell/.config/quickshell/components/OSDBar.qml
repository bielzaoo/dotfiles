import QtQuick
import Quickshell
import Quickshell.Wayland
import "../"

PanelWindow {
    id: root

    property real value: 0
    property string label: ""
    property bool danger: false

    function show() {
        root.shown = true
        hideTimer.restart()
    }

    property bool shown: false

    WlrLayershell.layer: WlrLayer.Overlay
    focusable: false
    exclusiveZone: 0
    color: "transparent"
    visible: root.shown

    anchors.bottom: true
    margins.bottom: 90

    implicitWidth: 220
    implicitHeight: 50

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.backgroundAlt
        radius: 8
        border.color: root.danger ? Colors.danger : Colors.accentDim
        border.width: 1

        Item {
            anchors.fill: parent
            anchors.margins: 14

            Text {
                id: labelText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                color: root.danger ? Colors.danger : Colors.textPrimary
                font.family: Fonts.family
                font.pixelSize: 11
                width: 34
            }

            Rectangle {
                id: track
                anchors.left: labelText.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: 3
                color: Colors.accentDim

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(1, root.value))
                    radius: 3
                    color: root.danger ? Colors.danger : Colors.accent
                }
            }
        }
    }
}
