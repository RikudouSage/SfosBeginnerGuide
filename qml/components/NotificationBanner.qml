import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root
    property alias message: textLabel.text
    property bool error: false
    signal dismissed()

    width: parent ? parent.width : Screen.width
    height: panel.height

    property int _margin: Theme.horizontalPageMargin

    Rectangle {
        id: panel
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: _margin
            rightMargin: _margin
        }
        radius: Theme.paddingSmall
        color: root.error ? Theme.errorColor : Theme.highlightBackgroundColor
        height: contentRow.height + Theme.paddingMedium * 2
        opacity: 1.0

        Row {
            id: contentRow
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            IconButton {
                id: closeButton
                icon.source: "image://theme/icon-m-close"
                onClicked: root.dismissed()
            }

            Label {
                id: textLabel
                width: parent.width - closeButton.width - Theme.paddingLarge
                wrapMode: Text.WordWrap
                color: Theme.primaryColor
            }
        }
    }

    PropertyAnimation {
        id: slideIn
        target: root
        property: "y"
        from: -root.height
        to: 0
        duration: 220
        easing.type: Easing.OutCubic
    }

    Component.onCompleted: slideIn.running = true
}
