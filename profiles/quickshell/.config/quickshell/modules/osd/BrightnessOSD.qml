import QtQuick
import Quickshell.Io
import "../../components"

OSDBar {
    id: root

    property real percent: 0

    value: percent / 100
    label: Math.round(percent) + "%"

    Process {
        id: brightnessProc
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(",")
                if (parts.length >= 4) {
                    root.percent = parseFloat(parts[3])
                }
            }
        }
    }

    function nudge(deltaPercent) {
        var arg = deltaPercent >= 0
            ? "+" + deltaPercent + "%"
            : Math.abs(deltaPercent) + "%-"
        brightnessProc.command = ["brightnessctl", "-m", "set", arg]
        brightnessProc.running = true
        root.show()
    }

    Component.onCompleted: {
        brightnessProc.command = ["brightnessctl", "-m", "info"]
        brightnessProc.running = true
    }
}
