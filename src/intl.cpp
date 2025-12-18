#include "intl.h"

#include <QLocale>

Intl::Intl(QObject *parent) : QObject(parent)
{

}

const QString Intl::nativeLanguageName(const QString &languageCode) const
{
    const QLocale locale(languageCode);
    if (locale.language() == QLocale::Language::English) {
        return "English"; // otherwise returns "American English"
    }

    auto name = locale.nativeLanguageName();
    name[0] = name[0].toUpper();

    return name;
}
