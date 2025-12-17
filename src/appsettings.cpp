#include "appsettings.h"

#include <QLocale>

AppSettings::AppSettings(QObject *parent) : QObject(parent)
{
    const auto systemLanguage = QLocale::languageToString(QLocale::system().language()).toLower();
    prop_language = settings->value("language", systemLanguage).toString();
    if (prop_language == "") {
        prop_language = systemLanguage;
    }
}

AppSettings::~AppSettings() {
    settings->sync();
}

const QString AppSettings::language() const
{
    return prop_language;
}

void AppSettings::setLanguage(const QString &value)
{
    if (value == prop_language) {
        return;
    }

    settings->setValue("language", value);
    prop_language = value;
    emit languageChanged();
}
