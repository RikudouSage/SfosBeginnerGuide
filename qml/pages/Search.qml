import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Search"
                title: qsTrId("app-search")
            }

            Label {
                //% "Search text"
                text: qsTrId("search-field-label")
                x: Theme.paddingLarge + Theme.paddingSmall
            }

            SearchField {
                id: searchField
                //% "How to install apps?"
                placeholderText: qsTrId("search-field-placeholder")
            }
        }
    }
}
