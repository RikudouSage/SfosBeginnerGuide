#ifndef INTL_H
#define INTL_H

#include <QObject>

class Intl : public QObject
{
    Q_OBJECT
public:
    explicit Intl(QObject *parent = nullptr);
    Q_INVOKABLE const QString nativeLanguageName(const QString &languageCode) const;

signals:

};

#endif // INTL_H
