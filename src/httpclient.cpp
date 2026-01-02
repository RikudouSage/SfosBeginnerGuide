#include "httpclient.h"

#include <QJSValueList>
#include <QBuffer>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QVariant>

RequestHandle::RequestHandle(QObject *parent)
    : QObject(parent)
{
}

bool RequestHandle::running() const
{
    return m_running;
}

bool RequestHandle::deleteOnFinish() const
{
    return m_deleteOnFinish;
}

void RequestHandle::cancel()
{
    m_deleteOnFinish = true;
    if (m_reply) {
        m_reply->abort();
    } else {
        deleteLater();
    }
}

void RequestHandle::setReply(QNetworkReply *reply)
{
    m_reply = reply;
    const bool wasRunning = m_running;
    m_running = (reply != nullptr);
    if (m_running != wasRunning) {
        emit runningChanged();
    }
}

HttpClient::HttpClient(QObject *parent) : QObject(parent)
{

}

QObject *HttpClient::sendRequest(const QString &method, const QString &url, const QJsonObject &body, const QJSValue &callback)
{
    RequestHandle *handle = new RequestHandle(this);
    QNetworkAccessManager *manager = new QNetworkAccessManager(handle);
    QNetworkRequest request((QUrl(url)));

    QByteArray payload;
    if (!body.isEmpty()) {
        payload = QJsonDocument(body).toJson(QJsonDocument::Compact);
        request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    }

    const QByteArray verb = method.toUtf8().toUpper();
    QNetworkReply *reply = nullptr;
    QBuffer *buffer = nullptr;

    if (verb == "GET") {
        reply = manager->get(request);
    } else if (verb == "POST") {
        reply = manager->post(request, payload);
    } else if (verb == "PUT") {
        reply = manager->put(request, payload);
    } else if (verb == "DELETE") {
        reply = manager->deleteResource(request);
    } else {
        buffer = new QBuffer(manager);
        buffer->setData(payload);
        buffer->open(QIODevice::ReadOnly);
        reply = manager->sendCustomRequest(request, verb, buffer);
    }

    QJSValue capturedCallback = callback;

    handle->setReply(reply);

    connect(reply, &QNetworkReply::finished, this, [reply, manager, buffer, handle, capturedCallback]() mutable {
        const bool canceled = (reply->error() == QNetworkReply::OperationCanceledError);

        if (!canceled) {
            const QByteArray responseBytes = reply->readAll();
            const QString responseText = QString::fromUtf8(responseBytes);
            const QVariant statusVar = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            const int statusCode = statusVar.isValid() ? statusVar.toInt() : -1;

            const bool networkOk = (reply->error() == QNetworkReply::NoError);
            const bool httpOk = (statusCode >= 200 && statusCode < 300) || !statusVar.isValid();
            const bool ok = networkOk && httpOk;

            if (capturedCallback.isCallable()) {
                capturedCallback.call(QJSValueList{ QJSValue(statusCode), QJSValue(responseText) });
            }

            if (handle) {
                emit handle->finished(ok, statusCode);
            }
        } else if (handle) {
            emit handle->finished(false, -1);
        }

        reply->deleteLater();
        if (buffer) {
            buffer->deleteLater();
        }
        manager->deleteLater();
        if (handle) {
            handle->setReply(nullptr);
            if (handle->deleteOnFinish()) {
                handle->deleteLater();
            }
        }
    });

    return handle;
}

QObject *HttpClient::sendRequest(const QString &url, const QJSValue &callback)
{
    return sendRequest("GET", url, QJsonObject(), callback);
}
