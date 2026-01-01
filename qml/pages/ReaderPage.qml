import QtQuick 2.0
import Sailfish.Silica 1.0

import dev.chrastecky 1.0

import "../components"

Page {
    property string pageToLoad: ''

    property var content: ({})
    property var links: []
    property var sections: []

    property bool loaded: false
    property bool notFound: false
    property bool genericError: false

    id: page
    allowedOrientations: defaultAllowedOrientations

    function hasAction(actionName) {
        return typeof content.meta !== 'undefined' &&
               typeof content.meta.actions !== 'undefined' &&
               content.meta.actions !== null &&
               content.meta.actions.indexOf(actionName) > -1;
    }

    function processText(text) {
        const highlight = Theme.rgba(Theme.highlightColor, 1);
        const primary = Theme.rgba(Theme.primaryColor, 1);

        const css = "<style>a {color: " + highlight + "; font-weight: bold; }</style>";

        // https://stackoverflow.com/a/1732454
        const regex = /<blockquote\b[^>]*>([\s\S]*?)<\/blockquote>/gi;
        text = text.replace(regex, function(_, inner) {
            return ""
              + "<table style='margin-top:" + Theme.paddingMedium + "px'><tr>"
              + "<td style='background-color: " + highlight + "'>&nbsp;</td>"
              + "<td style='padding-left: 8px'>" + inner + "</td>"
              + "</tr></table>";
        });

        return css + text;
    }

    function handleLoading() {
        pageTitle.title = content.meta.title;
        mainText.text = processText(content.content);
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

    LinkHandler {
        id: linkHandler
        //% "The requested app is not installed."
        onAppNotFound: notificationStack.push(qsTrId("error-link-handler-app-not-found"), true)
        //% "This type of link is not supported."
        onUnsupportedLinkType: notificationStack.push(qsTrId("error-link-handler-unknown-scheme"), true)
        //% "Could not open the link."
        onHandlingLinkFailed: notificationStack.push(qsTrId("error-link-handler-generic-error"), true)
        onStoreNotAvailable: {
            //% "Jolla Store"
            const storeName = qsTrId("app-jolla-store");
            //: This is for missing stores, the %1 will be replaced by a store name like Jolla Store, Storeman etc.
            //% "It seems you don't have %1 on your device."
            notificationStack.push(qsTrId("error-link-handler-no-store").arg(storeName), true)
        }
        onStoremanNotAvailable: {
            //% "Storeman"
            const storeName = qsTrId("app-storeman");
            //% "It seems you don't have %1 on your device."
            notificationStack.push(qsTrId("error-link-handler-no-store").arg(storeName), true)
        }
        onReaderPageRequested: pageStack.push("ReaderPage.qml", {pageToLoad: page})
    }

    NotificationStack {
        id: notificationStack
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Theme.paddingLarge
        }
    }

    BusyLabel {
        //: Inside a loader
        //% "Loading..."
        text: qsTrId("loading")
        running: !page.loaded
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            visible: appRoot.hasCapability('searching') || hasAction('settings') || hasAction('tutorial') || hasAction('jolla-store') || hasAction('storeman') || hasAction('chum')

            MenuItem {
                visible: appRoot.hasCapability('searching')
                //: Pull down menu item
                //% "Search"
                text: qsTrId("app-search")
                onClicked: pageStack.push("Search.qml")
            }

            MenuItem {
                visible: hasAction('settings')
                //: Pull down menu item
                //% "Settings"
                text: qsTrId("page-settings")
                onClicked: pageStack.push("Settings.qml")
            }

            MenuItem {
                visible: hasAction('tutorial')
                //: Pull down menu item
                //% "Tutorial"
                text: qsTrId("app-tutorial")
                onClicked: linkHandler.handleLink("start-app://sailfish-tutorial")
            }

            MenuItem {
                visible: hasAction('jolla-store')
                //: Pull down menu item
                //% "Jolla Store"
                text: qsTrId("app-jolla-store")
                onClicked: linkHandler.handleLink("start-app://store-client")
            }

            MenuItem {
                visible: hasAction('storeman')
                //: Pull down menu item
                //% "Storeman"
                text: qsTrId("app-storeman")
                onClicked: linkHandler.handleLink("start-app://harbour-storeman")
            }

            MenuItem {
                visible: hasAction('chum')
                //: Pull down menu item
                //% "Chum"
                text: qsTrId("app-chum")
                onClicked: linkHandler.handleLink("start-app://sailfishos-chum-gui")
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
                //% "The requested page wasn't found, please try again later"
                text: qsTrId("error-document-not-found")
            }
            Label {
                visible: genericError
                horizontalAlignment: Qt.AlignHCenter
                //% "There was an error while loading the page, please try again later"
                text: qsTrId("error-loading-failed")
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

                    onLinkActivated: {
                        linkHandler.handleLink(link);
                    }
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
                                    text: processText(modelData.content)
                                    wrapMode: Text.WordWrap
                                    width: parent.width - (Theme.paddingLarge * 2)
                                    x: Theme.paddingLarge
                                    textFormat: Text.RichText

                                    onLinkActivated: {
                                        linkHandler.handleLink(link);
                                    }
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
