import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../"

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
    }
    margins {
        top: 12
        right: 12
    }
    implicitWidth: 320
    implicitHeight: notifColumn.implicitHeight
    color: "transparent"
    exclusiveZone: 0

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true
        }
    }

    Column {
        id: notifColumn
        width: parent.width
        spacing: 8

        Repeater {
            model: notifServer.trackedNotifications

            delegate: Rectangle {
                id: notifCard
                required property var modelData

                width: parent.width
                implicitHeight: contentCol.implicitHeight + 20
                radius: 8
                color: Colors.backgroundAlt
                border.width: 2
                border.color: {
                    switch (modelData.urgency) {
                        case NotificationUrgency.Critical: return Colors.danger
                        case NotificationUrgency.Low: return Colors.textMuted
                        default: return Colors.accent
                    }
                }

                Timer {
                running: true
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                    onTriggered: modelData.tracked = false
                }

                Column {
                    id: contentCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 10
                    }
                    spacing: 4

                    Row {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: notifCard.modelData.appName || "Notificação"
                            color: Colors.textMuted
                            font.pixelSize: 10
                            width: parent.width - 20
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "×"
                            color: Colors.textMuted
                            font.pixelSize: 14

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notifCard.modelData.tracked = false
                            }
                        }
                    }

                    Text {
                        text: notifCard.modelData.summary
                        color: Colors.textPrimary
                        font.pixelSize: 13
                        font.bold: true
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        visible: notifCard.modelData.body.length > 0
                        text: notifCard.modelData.body
                        color: Colors.textPrimary
                        font.pixelSize: 12
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
