#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H

#include <QObject>
#include <QJsonObject>
#include <QJSValue>
#include <QPointer>

class QNetworkReply;

class HttpClient : public QObject
{
    Q_OBJECT
public:
    explicit HttpClient(QObject *parent = nullptr);
    Q_INVOKABLE QObject *sendRequest(
            const QString &method,
            const QString &url,
            const QJsonObject &body,
            const QJSValue &callback
    );
    Q_INVOKABLE QObject *sendRequest(
            const QString &url,
            const QJSValue &callback
    );

signals:

};

class RequestHandle : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
public:
    explicit RequestHandle(QObject *parent = nullptr);

    bool running() const;
    bool deleteOnFinish() const;

    Q_INVOKABLE void cancel();

    void setReply(QNetworkReply *reply);

signals:
    void runningChanged();
    void finished(bool ok, int statusCode);

private:
    QPointer<QNetworkReply> m_reply;
    bool m_running = false;
    bool m_deleteOnFinish = false;
};

#endif // HTTPCLIENT_H
