#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QCoreApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QGuiApplication>
#include <QLocale>
#include <QDebug>

#include <sailfishapp.h>

#include "appsettings.h"
#include "intl.h"
#include "linkhandler.h"

// todo don't hardcode
constexpr auto TRANSLATION_INSTALL_DIR = "/usr/share/harbour-beginner-guide/translations";

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    QTranslator *defaultLang = new QTranslator(app.data());
    if (!defaultLang->load("harbour-beginner-guide-en", TRANSLATION_INSTALL_DIR)) {
        qWarning() << "Could not load English translation file!";
    }
    QCoreApplication::installTranslator(defaultLang);

    QTranslator *translator = new QTranslator(app.data());
    if (!translator->load(QLocale::system(), "harbour-beginner-guide", "-", TRANSLATION_INSTALL_DIR)) {
        qWarning() << "Could not load translations for" << QLocale::system().name().toLatin1();
    } else {
        QCoreApplication::installTranslator(translator);
    }

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
