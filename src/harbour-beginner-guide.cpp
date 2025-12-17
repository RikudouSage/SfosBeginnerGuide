#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>

#include <sailfishapp.h>

#include "appsettings.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());

    v->rootContext()->setContextProperty("settings", new AppSettings(app.data()));

#ifdef QT_DEBUG
    v->rootContext()->setContextProperty("isDebug", true);
#else
    v->rootContext()->setContextProperty("isDebug", false);
#endif

    v->setSource(SailfishApp::pathToMainQml());
    v->show();

    return app->exec();
}
