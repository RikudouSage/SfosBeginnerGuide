#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QQuickView>
#include <QQmlContext>
#include <QGuiApplication>

#include <sailfishapp.h>

#include "appsettings.h"
#include "intl.h"
#include "linkhandler.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());

    v->rootContext()->setContextProperty("settings", new AppSettings(app.data()));

    qmlRegisterType<Intl>("dev.chrastecky", 1, 0, "Intl");
    qmlRegisterType<LinkHandler>("dev.chrastecky", 1, 0, "LinkHandler");

#ifdef QT_DEBUG
    v->rootContext()->setContextProperty("isDebug", true);
#else
    v->rootContext()->setContextProperty("isDebug", false);
#endif

    v->setSource(SailfishApp::pathToMainQml());
    v->show();

    return app->exec();
}
