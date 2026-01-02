import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/common.js" as Common
import "../components"

Page {
    property bool hasSearchError: false
    property var searchResults: []

    id: page
    allowedOrientations: defaultAllowedOrientations

    Timer {
        property bool inProgress: false
        property var currentHandle: null
        property string query

        function search(text) {
            stop();
            query = text;
            hasSearchError = false;
            searchResults = [];

            if (query !== "") {
                inProgress = true;
                restart();
            } else {
                inProgress = false;
            }

            if (currentHandle) {
                if (isDebug) {
                    console.log('Cancelling previous search request')
                }
                currentHandle.cancel();
                currentHandle = null;
            }
        }

        id: searchDebouncer
        interval: 300
        repeat: false

        onTriggered: {
            var language = settings.language;
            if (appRoot.languages.indexOf(settings.language) < 0) {
                language = "en";
            }
            const searchUrl = apiUrl + '/search/' + language;

            if (isDebug) {
                console.log('Sending a QUERY request to ' + searchUrl);
            }
            currentHandle = httpClient.sendRequest("QUERY", searchUrl, {
                "query": query
            }, function (statusCode, body) {
                try {
                    if (isDebug) {
                        console.log('Got response from ' + searchUrl + ': ' + statusCode);
                    }

                    if (statusCode !== 200) {
                        console.error(body);
                        page.hasSearchError = true;
                        return;
                    }

                    const fetchedResults = [];
                    const results = JSON.parse(body);
                    var completed = 0;
                    for (var index in results) {
                        if (!results.hasOwnProperty(index)) {
                            continue;
                        }

                        const result = results[index];
                        fetchedResults[index] = {};

                        (function(index, result) {
                            Common.fetchDocument(result.source, function (statusCode, body) {
                                fetchedResults[index] = {title: body.meta.title, link: result.source, score: result.score};
                                ++completed;

                                if (completed !== results.length) {
                                    return;
                                }

                                searchResults = fetchedResults;
                            });
                        })(index, result)
                    }

                } finally {
                    currentHandle = null;
                    inProgress = false;
                }
            });
        }
    }

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

            SearchField {
                id: searchField
                //% "How to install apps?"
                placeholderText: qsTrId("search-field-placeholder")
                //% "Search text"
                label: qsTrId("search-field-label")
                onTextChanged: searchDebouncer.search(searchField.text);
                focus: true
                active: true
            }

            Label {
                //% "There was an error while searching, please try again later."
                text: qsTrId("error-search-generic")
                visible: hasSearchError
                x: Theme.paddingLarge
                color: Theme.errorColor
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.Wrap
            }

            BusyLabel {
                //% "Searching..."
                text: qsTrId("search-in-progress")
                running: searchDebouncer.inProgress
            }

            Repeater {
                model: searchResults

                LinkButton {
                    text: modelData.title
                    onClicked: {
                        pageStack.push("ReaderPage.qml", {pageToLoad: modelData.link});
                    }

                    Component.onCompleted: {
                        if (isDebug) {
                            console.log(JSON.stringify(modelData));
                        }
                    }
                }
            }
        }
    }
}
