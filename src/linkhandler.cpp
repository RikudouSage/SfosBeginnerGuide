#include "linkhandler.h"

#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QStandardPaths>
#include <QFile>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QTimer>

static const auto SchemeHttp = QStringLiteral("http");
static const auto SchemeHttps = QStringLiteral("https");
static const auto SchemeOpenApp = QStringLiteral("start-app");
static const auto SchemeDocument = QStringLiteral("document");
static const auto SchemeJollaStore = QStringLiteral("jolla-store");
static const auto SchemeStoreman = QStringLiteral("storeman");

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
    } else if (url.scheme() == SchemeJollaStore) {
        handleJollaStoreLink(link);
    } else if (url.scheme() == SchemeStoreman) {
        handleStoremanLink(link);
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

void LinkHandler::handleJollaStoreLink(const QString &url)
{
    const auto appName = QString(url).mid(SchemeJollaStore.length() + QStringLiteral("://").length());

    auto bus = QDBusConnection::sessionBus();
    auto *busIface = bus.interface();
    if (!busIface) {
        emit handlingLinkFailed();
        return;
    }

    if (!busIface->isServiceRegistered(QStringLiteral("com.jolla.jollastore"))) {
        emit storeNotAvailable();
        return;
    }

    QDBusInterface storeIface(
        QStringLiteral("com.jolla.jollastore"),
        QStringLiteral("/StoreClient"),
        QStringLiteral("com.jolla.jollastore"),
        bus
    );

    if (!storeIface.isValid()) {
        emit handlingLinkFailed();
        return;
    }

    QDBusPendingCall call = storeIface.asyncCall(QStringLiteral("showApp"), appName);
    auto *watcher = new QDBusPendingCallWatcher(call, this);

    auto *timeout = new QTimer(watcher);
    timeout->setSingleShot(true);
    timeout->start(1500);

    connect(timeout, &QTimer::timeout, this, [this, watcher]() {
        watcher->deleteLater();
        emit handlingLinkFailed();
    });

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, timeout]() {
        timeout->stop();

        QDBusPendingReply<> reply = *watcher;
        watcher->deleteLater();

        if (reply.isError()) {
            emit handlingLinkFailed();
            return;
        }
    });
}

void LinkHandler::handleStoremanLink(const QString &url)
{
    const QString appIdStr = QString(url).mid(
        SchemeStoreman.length() + QStringLiteral("://").length()
    );

    bool ok = false;
    const int appId = appIdStr.toInt(&ok);
    if (!ok || appId <= 0) {
        emit handlingLinkFailed();
        return;
    }

    auto bus = QDBusConnection::sessionBus();
    auto *busIface = bus.interface();
    if (!busIface) {
        emit handlingLinkFailed();
        return;
    }

    const QString service = QStringLiteral("harbour.storeman.service");
    if (!busIface->isServiceRegistered(service)) {
        emit storemanNotAvailable();
        return;
    }

    QDBusInterface storemanIface(
        service,
        QStringLiteral("/harbour/storeman/service"),
        QStringLiteral("harbour.storeman.service"),
        bus
    );

    if (!storemanIface.isValid()) {
        emit handlingLinkFailed();
        return;
    }

    QVariantMap args;
    args.insert("appId", appId);

    QDBusPendingCall call = storemanIface.asyncCall(
        QStringLiteral("openPage"),
        QStringLiteral("AppPage"),
        args
    );

    auto *watcher = new QDBusPendingCallWatcher(call, this);

    auto *timeout = new QTimer(watcher);
    timeout->setSingleShot(true);
    timeout->start(1500);

    connect(timeout, &QTimer::timeout, this, [this, watcher]() {
        watcher->deleteLater();
        emit handlingLinkFailed();
    });

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, timeout]() {
        timeout->stop();

        QDBusPendingReply<> reply = *watcher;
        watcher->deleteLater();

        if (reply.isError()) {
            emit handlingLinkFailed();
            return;
        }
    });
}
