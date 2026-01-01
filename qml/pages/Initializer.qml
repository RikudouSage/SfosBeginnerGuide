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

        const xhrLang = new XMLHttpRequest();
        xhrLang.open("GET", urlLang, true);
        xhrLang.onreadystatechange = function() {
            if (xhrLang.readyState === XMLHttpRequest.DONE) {
                if (xhrLang.status === 200) {
                    appRoot.languages = JSON.parse(xhrLang.responseText);
                } else {
                    console.error("Failed getting a list of available languages from the api");
                    appRoot.languages = ["en"];
                }

                languagesFetched = true;
                redirectOnReady();
            }
        };
        xhrLang.send();

        const xhrCapabilities = new XMLHttpRequest();
        xhrCapabilities.open("GET", urlCapabilities, true);
        xhrCapabilities.onreadystatechange = function() {
            if (xhrCapabilities.readyState === XMLHttpRequest.DONE) {
                if (xhrCapabilities.status === 200) {
                    appRoot.capabilities = JSON.parse(xhrCapabilities.responseText);
                } else {
                    console.error("Failed getting capabitilies from the api");
                    appRoot.capabilities = {};
                }

                capabilitiesReady = true;
                redirectOnReady();
            }
        };
        xhrCapabilities.send();
    }
}
