import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    property string pageToLoad: ''

    property bool settingsAvailable: typeof content.meta !== 'undefined' &&
                                     typeof content.meta.actions !== 'undefined' &&
                                     content.meta.actions.indexOf('settings') > -1;

    property var content: ({})
    property var links: []
    property var sections: []

    property bool loaded: false
    property bool notFound: false
    property bool genericError: false

    id: page
    allowedOrientations: defaultAllowedOrientations

    function handleLoading() {
        pageTitle.title = content.meta.title;
        mainText.text = content.content;
        page.loaded = true;

        if (typeof content.links !== 'undefined') {
            links = content.links;
        }
        if (typeof content.sections !== 'undefined') {
            sections = content.sections;
        }

        if (isDebug) {
            console.log(JSON.stringify(content))
        }
    }

    BusyLabel {
        //: Inside a loader
        text: qsTr("Loading...")
        running: !page.loaded
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            visible: settingsAvailable // add other conditions here if more actions become available

            MenuItem {
                visible: settingsAvailable
                //: Pull down menu item
                text: qsTr("Settings")
                onClicked: pageStack.push("Settings.qml")
            }
        }

        Column {
            id: column
            width: page.width

            PageHeader {
                id: pageTitle
            }

            Label {
                visible: notFound
                horizontalAlignment: Qt.AlignHCenter
                //: Error message
                text: qsTr("The requested page wasn't found, please try again later")
            }
            Label {
                visible: genericError
                horizontalAlignment: Qt.AlignHCenter
                //: Error message
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

                Repeater {
                    id: sectionsRepeater
                    model: sections

                    ExpandingSectionGroup { // animations don't work without this
                        currentIndex: -1

                        ExpandingSection {
                            title: modelData.title

                            content.sourceComponent: Column {
                                Label {
                                    text: modelData.content
                                    wrapMode: Text.WordWrap
                                    width: parent.width - (Theme.paddingLarge * 2)
                                    x: Theme.paddingLarge
                                    textFormat: Text.RichText
                                }
                            }
                        }
                    }
                }

                Repeater {
                    id: linksRepeater
                    model: links

                    LinkButton {
                        text: modelData.title
                        onClicked: {
                            pageStack.push("ReaderPage.qml", {pageToLoad: modelData.link});
                        }
                    }
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

        if (pageToLoad.indexOf(language + "/") === 0) {
            pageToLoad = pageToLoad.substring((language + "/").length);
        }

        const pageUrl = apiUrl + '/' + language + '/' + pageToLoad;

        if (isDebug) {
            console.log('Sending GET request to ' + pageUrl);
        }

        const xhr = new XMLHttpRequest();
        xhr.open("GET", pageUrl, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (isDebug) {
                    console.log('Got response from ' + pageUrl + ': ' + xhr.status);
                }
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
