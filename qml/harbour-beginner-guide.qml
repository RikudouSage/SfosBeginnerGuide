import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    readonly property string apiUrl: 'https://sfbg.chrastecky.dev'
    property var languages: []
    property var capabilities: ({})

    function hasCapability(name) {
        if (typeof capabilities[name] === 'undefined') {
            return false;
        }

        return capabilities[name];
    }

    id: appRoot

    initialPage: Component { Initializer {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
