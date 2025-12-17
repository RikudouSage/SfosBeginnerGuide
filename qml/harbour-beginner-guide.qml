import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    readonly property string apiUrl: 'https://sfbg.chrastecky.dev'
    property var languages: []

    id: appRoot

    initialPage: Component { LanguageLoader {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
