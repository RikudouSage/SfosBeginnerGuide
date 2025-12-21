import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    BusyLabel {
        //: Inside a loader
        text: qsTr("Loading...")
        running: true
    }

    Component.onCompleted: {
        const url = appRoot.apiUrl + '/languages';

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    appRoot.languages = JSON.parse(xhr.responseText);
                } else {
                    console.error("Failed getting a list of available languages from the api");
                    appRoot.languages = ["en"];
                }

                pageStack.replace("ReaderPage.qml")
            }
        }
        xhr.send();
    }
}
