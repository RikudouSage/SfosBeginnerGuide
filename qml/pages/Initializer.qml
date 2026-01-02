import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property bool languagesFetched: false
    property bool capabilitiesReady: false

    id: page
    allowedOrientations: defaultAllowedOrientations

    function redirectOnReady() {
        if (languagesFetched && capabilitiesReady) {
            pageStack.replace("ReaderPage.qml");
        }
    }

    BusyLabel {
        //: Inside a loader
        //% "Loading..."
        text: qsTrId("loading")
        running: true
    }

    Component.onCompleted: {
        const urlLang = appRoot.apiUrl + '/languages';
        const urlCapabilities = appRoot.apiUrl + '/capabilities';

        httpClient.sendRequest(urlLang, function(statusCode, body) {
            if (statusCode === 200) {
                appRoot.languages = JSON.parse(body);
            } else {
                console.error("Failed getting a list of available languages from the api");
                appRoot.languages = ["en"];
            }

            languagesFetched = true;
            redirectOnReady();
        });

        httpClient.sendRequest(urlCapabilities, function(statusCode, body) {
            if (statusCode === 200) {
                appRoot.capabilities = JSON.parse(body);
            } else {
                console.error("Failed getting capabitilies from the api");
                appRoot.capabilities = {};
            }

            capabilitiesReady = true;
            redirectOnReady();
        });
    }
}
