#include "linkhandler.h"

#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QStandardPaths>
#include <QFile>

static const auto SchemeHttp = QStringLiteral("http");
static const auto SchemeHttps = QStringLiteral("https");
static const auto SchemeOpenApp = QStringLiteral("start-app");
static const auto SchemeNone = QStringLiteral("");

LinkHandler::LinkHandler(QObject *parent) : QObject(parent)
{
}

void LinkHandler::handleLink(const QString &link, const QString &currentPage)
{
    const QUrl url(link);

    if (url.scheme() == SchemeHttp || url.scheme() == SchemeHttps) {
        handleExternalLink(link);
    } else if (url.scheme() == SchemeOpenApp) {
        handleAppLink(link);
    } else if (url.scheme() == SchemeNone) {
        handleDocumentLink(link, currentPage);
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
            QDesktopServices::openUrl(QUrl::fromLocalFile(potentialPath));
            return;
        }
    }

    emit appNotFound();
}

void LinkHandler::handleExternalLink(const QString &url)
{
    QDesktopServices::openUrl(QUrl(url));
}

void LinkHandler::handleDocumentLink(const QString &url, const QString &currentUrl)
{
    qDebug() << url << currentUrl;
}
