import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Row {
    id: root
    spacing: 12

    property real cpuUsage: 0
    property real ramUsage: 0

    // snapshot anterior de /proc/stat, pra calcular o delta de CPU
    property real _prevTotal: -1
    property real _prevIdle: -1

    Row {
        spacing: 4
        Text {
            text: "CPU"
            color: Colors.textMuted
            font.pixelSize: 11
        }
        Text {
            text: Math.round(root.cpuUsage) + "%"
            color: Colors.textPrimary
            font.pixelSize: 11
            font.bold: true
        }
    }

    Row {
        spacing: 4
        Text {
            text: "RAM"
            color: Colors.textMuted
            font.pixelSize: 11
        }
        Text {
            text: Math.round(root.ramUsage) + "%"
            color: Colors.textPrimary
            font.pixelSize: 11
            font.bold: true
        }
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        watchChanges: false
        onLoaded: {
            var line = text().split("\n")[0] // primeira linha: "cpu  user nice system idle iowait irq softirq ..."
            var parts = line.trim().split(/\s+/).slice(1).map(Number)
            var idle = parts[3]
            var total = parts.reduce((a, b) => a + b, 0)

            if (root._prevTotal >= 0) {
                var dTotal = total - root._prevTotal
                var dIdle = idle - root._prevIdle
                if (dTotal > 0) {
                    root.cpuUsage = (dTotal - dIdle) / dTotal * 100
                }
            }
            root._prevTotal = total
            root._prevIdle = idle
        }
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        watchChanges: false
        onLoaded: {
            var content = text()
            var totalMatch = content.match(/MemTotal:\s+(\d+)/)
            var availMatch = content.match(/MemAvailable:\s+(\d+)/)
            if (totalMatch && availMatch) {
                var total = parseFloat(totalMatch[1])
                var avail = parseFloat(availMatch[1])
                root.ramUsage = (total - avail) / total * 100
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
        }
    }
}
