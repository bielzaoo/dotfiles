import QtQuick
import Quickshell
import Quickshell.Io
import "../../"

Row {
    id: root
    spacing: 12

    property real cpuUsage: 0
    property real ramUsage: 0

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

    Process {
        id: statsProc
        command: ["bash", "-c",
            "cpu1=($(grep '^cpu ' /proc/stat)); " +
            "sleep 0.4; " +
            "cpu2=($(grep '^cpu ' /proc/stat)); " +
            "idle1=${cpu1[4]}; idle2=${cpu2[4]}; " +
            "total1=0; for v in ${cpu1[@]:1}; do total1=$((total1+v)); done; " +
            "total2=0; for v in ${cpu2[@]:1}; do total2=$((total2+v)); done; " +
            "dtotal=$((total2-total1)); didle=$((idle2-idle1)); " +
            "cpupct=$(awk -v dt=$dtotal -v di=$didle 'BEGIN { if (dt>0) printf \"%.1f\", (dt-di)/dt*100; else print 0 }'); " +
            "mem=$(free | grep Mem); " +
            "mtotal=$(echo $mem | awk '{print $2}'); " +
            "mused=$(echo $mem | awk '{print $3}'); " +
            "mpct=$(awk -v u=$mused -v t=$mtotal 'BEGIN { printf \"%.1f\", u/t*100 }'); " +
            "echo \"$cpupct,$mpct\""
        ]

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(",")
                if (parts.length === 2) {
                    root.cpuUsage = parseFloat(parts[0])
                    root.ramUsage = parseFloat(parts[1])
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }
}
