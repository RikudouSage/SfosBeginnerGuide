import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string pageToLoad: ''
    property var content: ({})

    property bool loaded: false
    property bool notFound: false
    property bool genericError: false

    id: page
    allowedOrientations: defaultAllowedOrientations

    function handleLoading() {
        pageTitle.title = content.meta.title;
        mainText.text = content.content;
        page.loaded = true;
    }

    BusyLabel {
        text: qsTr("Loading...")
        running: !page.loaded
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                id: pageTitle
            }

            Label {
                visible: notFound
                horizontalAlignment: Qt.AlignHCenter
                text: qsTr("The requested page wasn't found, please try again later")
            }
            Label {
                visible: genericError
                horizontalAlignment: Qt.AlignHCenter
                text: qsTr("There was an error while loading the page, please try again later")
                padding: Theme.paddingLarge
            }

            Column {
                visible: !notFound && !genericError && loaded
                width: parent.width
                spacing: Theme.paddingLarge

                Label {
                    id: mainText
                    wrapMode: Text.WordWrap
                    width: parent.width - (Theme.paddingLarge * 2)
                    x: Theme.paddingLarge
                    textFormat: Text.RichText
                }
            }
        }
    }

    Component.onCompleted: {
        while (pageToLoad.indexOf('/') === 0) {
            pageToLoad = pageToLoad.substring(1);
        }

        var language = settings.language;
        if (appRoot.languages.indexOf(settings.language) < 0) {
            language = "en";
        }

        const pageUrl = apiUrl + '/' + language + '/' + pageToLoad;

        const xhr = new XMLHttpRequest();
        xhr.open("GET", pageUrl, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    page.content = JSON.parse(xhr.responseText);
                    page.handleLoading();
                } else if (xhr.status === 404) {
                    page.notFound = true;
                    page.loaded = true;
                } else {
                    page.genericError = true;
                    page.loaded = true;
                }
            }
        };
        xhr.send();
    }
}
