#ifndef LINKHANDLER_H
#define LINKHANDLER_H

#include <QObject>

class LinkHandler : public QObject
{
    Q_OBJECT
public:
    explicit LinkHandler(QObject *parent = nullptr);
    Q_INVOKABLE void handleLink(const QString &link);

signals:
    void appNotFound();
    void unsupportedLinkType();
    void handlingLinkFailed();
    void readerPageRequested(const QString &page);
    void storeNotAvailable();
    void storemanNotAvailable();

private:
    void handleAppLink(const QString &url);
    void handleExternalLink(const QString &url);
    void handleDocumentLink(const QString &link);
    void handleJollaStoreLink(const QString &url);
    void handleStoremanLink(const QString &url);
};

#endif // LINKHANDLER_H
