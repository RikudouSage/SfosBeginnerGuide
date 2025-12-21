#include "linkhandler.h"

#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QStandardPaths>
#include <QFile>

static const auto SchemeHttp = QStringLiteral("http");
static const auto SchemeHttps = QStringLiteral("https");
static const auto SchemeOpenApp = QStringLiteral("start-app");
static const auto SchemeDocument = QStringLiteral("document");

LinkHandler::LinkHandler(QObject *parent) : QObject(parent)
{
}

void LinkHandler::handleLink(const QString &link)
{
    const QUrl url(link);

    if (url.scheme() == SchemeHttp || url.scheme() == SchemeHttps) {
        handleExternalLink(link);
    } else if (url.scheme() == SchemeOpenApp) {
        handleAppLink(link);
    } else if (url.scheme() == SchemeDocument) {
        handleDocumentLink(link);
    } else {
        emit unsupportedLinkType();
    }
}

void LinkHandler::handleAppLink(const QString &url)
{
    const auto appName = QString(url).mid(SchemeOpenApp.length() + QStringLiteral("://").length());
    const auto prefixes = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);

    for (const auto &prefix : prefixes) {
        const auto potentialPath = prefix + "/applications/" + appName + ".desktop";
        if (QFile(potentialPath).exists()) {
            if (!QDesktopServices::openUrl(QUrl::fromLocalFile(potentialPath))) {
                emit handlingLinkFailed();
            }
            return;
        }
    }

    emit appNotFound();
}

void LinkHandler::handleExternalLink(const QString &url)
{
    if (!QDesktopServices::openUrl(QUrl(url))) {
        emit handlingLinkFailed();
    }
}

void LinkHandler::handleDocumentLink(const QString &link)
{
    const QUrl url(link);
    emit readerPageRequested(url.path());
}
