# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-beginner-guide

CONFIG += sailfishapp
QT += dbus

SOURCES += src/harbour-beginner-guide.cpp \
    src/appsettings.cpp \
    src/intl.cpp \
    src/linkhandler.cpp

DISTFILES += qml/harbour-beginner-guide.qml \
    qml/components/NotificationBanner.qml \
    qml/components/NotificationStack.qml \
    qml/components/LinkButton.qml \
    qml/cover/CoverPage.qml \
    qml/pages/Initializer.qml \
    qml/pages/ReaderPage.qml \
    qml/pages/Search.qml \
    qml/pages/Settings.qml \
    rpm/harbour-beginner-guide.changes.in \
    rpm/harbour-beginner-guide.changes.run.in \
    rpm/harbour-beginner-guide.spec \
    translations/*.ts \
    harbour-beginner-guide.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-beginner-guide-en.ts \
                translations/harbour-beginner-guide-de.ts \
                translations/harbour-beginner-guide-nb.ts \
                translations/harbour-beginner-guide-cs.ts

HEADERS += \
    src/appsettings.h \
    src/intl.h \
    src/linkhandler.h
