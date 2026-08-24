import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../"

PanelWindow {
    id: root

    property bool shown: false
    property string query: ""
    property int selectedIndex: 0

    readonly property var results: {
        var q = query.toLowerCase()
        var all = DesktopEntries.applications.values.filter(e => !e.noDisplay)
        var filtered = q.length === 0 ? all : all.filter(e => e.name.toLowerCase().includes(q))
        filtered.sort((a, b) => a.name.localeCompare(b.name))
        return filtered.slice(0, 9)
    }

    function toggle() {
        root.shown = !root.shown
        if (root.shown) {
            query = ""
            selectedIndex = 0
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    function launch(entry) {
        if (!entry) return
        entry.execute()
        root.shown = false
    }

    onQueryChanged: root.selectedIndex = 0

    WlrLayershell.layer: WlrLayer.Overlay
    focusable: root.shown
    exclusiveZone: -1
    color: "transparent"
    visible: root.shown

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Rectangle {
        anchors.centerIn: parent
        width: 480
        height: 380
        radius: 10
        color: Colors.backgroundAlt
        border.color: Colors.accentDim
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Rectangle {
                width: parent.width
                height: 36
                radius: 6
                color: Colors.background
                border.color: Colors.accent
                border.width: 1

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Colors.textPrimary
                    font.family: Fonts.family
                    font.pixelSize: 14
                    clip: true

                    onTextChanged: root.query = text

                    Keys.onEscapePressed: root.shown = false
                    Keys.onDownPressed: root.selectedIndex = Math.min(root.selectedIndex + 1, root.results.length - 1)
                    Keys.onUpPressed: root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                    Keys.onReturnPressed: root.launch(root.results[root.selectedIndex])
                }
            }

            ListView {
                width: parent.width
                height: parent.height - 46
                clip: true
                model: root.results
                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    id: delegateRoot
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 34
                    radius: 4
                    color: index === root.selectedIndex ? Colors.accentDim : "transparent"

                    Image {
                        id: iconImage
                        readonly property string iconName: delegateRoot.modelData.icon || ""
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                        sourceSize: Qt.size(18, 18)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        visible: status === Image.Ready
                        source: iconName.length === 0
                            ? ""
                            : iconName.startsWith("/") ? "file://" + iconName : "image://icon/" + iconName
                    }

                    Text {
                        anchors.left: iconImage.left
                        anchors.leftMargin: iconImage.visible ? iconImage.width + 8 : 0
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: delegateRoot.modelData.name
                        color: Colors.textPrimary
                        font.family: Fonts.family
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedIndex = delegateRoot.index
                        onClicked: root.launch(delegateRoot.modelData)
                    }
                }
            }
        }
    }
}
