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
    qInfo() << "LinkHandler: handling link" << link;
    const QUrl url(link);

    if (url.scheme() == SchemeHttp || url.scheme() == SchemeHttps) {
        qInfo() << "LinkHandler: external link" << url;
        handleExternalLink(link);
    } else if (url.scheme() == SchemeOpenApp) {
        qInfo() << "LinkHandler: app link" << url;
        handleAppLink(link);
    } else if (url.scheme() == SchemeDocument) {
        qInfo() << "LinkHandler: document link" << url;
        handleDocumentLink(link);
    } else if (url.scheme() == SchemeJollaStore) {
        qInfo() << "LinkHandler: Jolla Store link" << url;
        handleJollaStoreLink(link);
    } else if (url.scheme() == SchemeStoreman) {
        qInfo() << "LinkHandler: Storeman link" << url;
        handleStoremanLink(link);
    } else {
        qWarning() << "LinkHandler: unsupported link type" << url;
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
            qInfo() << "LinkHandler: opening desktop file" << potentialPath;
            if (!QDesktopServices::openUrl(QUrl::fromLocalFile(potentialPath))) {
                qWarning() << "LinkHandler: failed to open desktop file" << potentialPath;
                emit handlingLinkFailed();
            }
            return;
        }
    }

    qWarning() << "LinkHandler: app desktop file not found for" << appName;
    emit appNotFound();
}

void LinkHandler::handleExternalLink(const QString &url)
{
    qInfo() << "LinkHandler: opening external URL" << url;
    if (!QDesktopServices::openUrl(QUrl(url))) {
        qWarning() << "LinkHandler: failed to open external URL" << url;
        emit handlingLinkFailed();
    }
}

void LinkHandler::handleDocumentLink(const QString &link)
{
    const QUrl url(link);
    qInfo() << "LinkHandler: requesting reader page for" << url.path();
    emit readerPageRequested(url.path());
}

void LinkHandler::handleJollaStoreLink(const QString &url)
{
    const auto appName = QString(url).mid(SchemeJollaStore.length() + QStringLiteral("://").length());
    qInfo() << "LinkHandler: requesting Jolla Store app" << appName;

    auto bus = QDBusConnection::sessionBus();
    auto *busIface = bus.interface();
    if (!busIface) {
        qWarning() << "LinkHandler: failed to get session bus interface";
        emit handlingLinkFailed();
        return;
    }

    if (!busIface->isServiceRegistered(QStringLiteral("com.jolla.jollastore"))) {
        qWarning() << "LinkHandler: Jolla Store service not available";
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
        qWarning() << "LinkHandler: Jolla Store DBus interface invalid";
        emit handlingLinkFailed();
        return;
    }

    QDBusPendingCall call = storeIface.asyncCall(QStringLiteral("showApp"), appName);
    auto *watcher = new QDBusPendingCallWatcher(call, this);

    auto *timeout = new QTimer(watcher);
    timeout->setSingleShot(true);
    timeout->start(1500);

    connect(timeout, &QTimer::timeout, this, [this, watcher]() {
        qWarning() << "LinkHandler: Jolla Store call timed out";
        watcher->deleteLater();
        emit handlingLinkFailed();
    });

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, timeout]() {
        timeout->stop();

        QDBusPendingReply<> reply = *watcher;
        watcher->deleteLater();

        if (reply.isError()) {
            qWarning() << "LinkHandler: Jolla Store call failed" << reply.error().name()
                       << reply.error().message();
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
        qWarning() << "LinkHandler: invalid Storeman app id" << appIdStr;
        emit handlingLinkFailed();
        return;
    }

    qInfo() << "LinkHandler: requesting Storeman app" << appId;

    auto bus = QDBusConnection::sessionBus();
    auto *busIface = bus.interface();
    if (!busIface) {
        qWarning() << "LinkHandler: failed to get session bus interface";
        emit handlingLinkFailed();
        return;
    }

    const QString service   = QStringLiteral("harbour.storeman.service");
    const QString path      = QStringLiteral("/harbour/storeman/service");
    const QString ifaceName = QStringLiteral("harbour.storeman.service");

    QDBusInterface storemanIface(service, path, ifaceName, bus);
    if (!storemanIface.isValid()) {
        qInfo() << "LinkHandler: Storeman iface not valid yet (may be activatable), continuing anyway";
    }

    QVariantMap args;
    args.insert(QStringLiteral("appId"), appId);

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
        qWarning() << "LinkHandler: Storeman call timed out";
        watcher->deleteLater();
        emit handlingLinkFailed();
    });

    connect(watcher, &QDBusPendingCallWatcher::finished, this,
            [this, watcher, timeout, service, path, ifaceName, args]() {
        timeout->stop();

        QDBusPendingReply<> reply = *watcher;
        watcher->deleteLater();

        if (!reply.isError()) {
            return;
        }

        const auto err = reply.error();
        qWarning() << "LinkHandler: Storeman call failed" << err.name() << err.message();
        if (err.name() == "org.freedesktop.DBus.Error.ServiceUnknown") {
            emit storemanNotAvailable();
            return;
        }

        emit handlingLinkFailed();
    });
}
