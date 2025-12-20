import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root
    property int spacing: Theme.paddingSmall
    property alias count: notifications.count

    width: parent ? parent.width : Screen.width
    anchors {
        top: parent ? parent.top : undefined
        left: parent ? parent.left : undefined
        right: parent ? parent.right : undefined
    }
    z: 99

    ListModel {
        id: notifications
    }

    function push(message, error) {
        notifications.append({ text: message, error: error })
    }

    Column {
        id: stack
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: root.spacing

        Repeater {
            id: repeater
            model: notifications

            NotificationBanner {
                width: stack.width
                message: model.text
                error: model.error
                onDismissed: notifications.remove(index)
            }
        }
    }
}
