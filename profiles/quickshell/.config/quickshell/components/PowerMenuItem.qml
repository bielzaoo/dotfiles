import QtQuick
import "../"

Rectangle {
    id: itemRoot
    property string label: ""
    property bool isDanger: false
    signal clicked()

    width: parent.width
    height: 26
    radius: 4
    color: mouseArea.containsMouse ? Colors.accentDim : "transparent"

    Text {
        anchors.centerIn: parent
        text: itemRoot.label
        color: itemRoot.isDanger ? Colors.danger : Colors.textPrimary
        font.pixelSize: 12
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: itemRoot.clicked()
    }
}
