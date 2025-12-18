#include "appsettings.h"

#include <QLocale>

AppSettings::AppSettings(QObject *parent) : QObject(parent)
{

    prop_language = settings->value("language", "").toString();
}

AppSettings::~AppSettings() {
    settings->sync();
}

const QString AppSettings::language() const
{
    if (prop_language != "") {
        return prop_language;
    }

    return QLocale::languageToString(QLocale::system().language()).toLower();
}

void AppSettings::setLanguage(const QString &value)
{
    setRawLanguage(value);
}

const QString AppSettings::rawLanguage() const
{
    return prop_language;
}

void AppSettings::setRawLanguage(const QString &value)
{
    if (value == prop_language) {
        return;
    }

    settings->setValue("language", value);
    prop_language = value;

    emit languageChanged();
    emit rawLanguageChanged();
}
