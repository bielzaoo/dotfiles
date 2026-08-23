import QtQuick
import "../../"

Item {
    id: root
    implicitWidth: clockText.implicitWidth + 16
    implicitHeight: parent.height

    property string timeFormat: "hh:mm"
    property string dateFormat: "dd MMM"

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Colors.textPrimary
        font.pixelSize: 13
        font.bold: true

        function updateTime() {
            var now = new Date()
            text = Qt.formatDateTime(now, root.timeFormat) + "   " + Qt.formatDateTime(now, root.dateFormat)
        }

        Component.onCompleted: updateTime()

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.updateTime()
        }
    }
}
