import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow {
    property bool isDebug: false
    readonly property string apiUrl: 'https://sfbg.chrastecky.dev'
    property var languages: []

    id: appRoot

    readonly property string systemLanguage: Qt.locale().name.split('_')[0]

    ConfigurationGroup {
        id: settings
        path: '/apps/harbour-beginner-guide/'

        property string language: systemLanguage
    }

    initialPage: Component { LanguageLoader {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
