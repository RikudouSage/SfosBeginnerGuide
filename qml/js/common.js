function fetchDocument(pageToLoad, callback) {
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

    var pageUrl = apiUrl + '/' + language + '/' + pageToLoad;

    if (isDebug) {
        console.log('Sending GET request to ' + pageUrl);
    }

    httpClient.sendRequest(pageUrl, function(statusCode, body) {
        if (isDebug) {
            console.log('Got response from ' + pageUrl + ': ' + statusCode);
        }

        callback(statusCode, JSON.parse(body));
    });
}
