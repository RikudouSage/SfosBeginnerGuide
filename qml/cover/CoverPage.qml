import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: Theme.paddingLarge

        Label {
            //% "Beginner's Guide"
            text: qsTrId("app-title")
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
