#ifndef PILORAMA_MACOSCONTROLLER_H
#define PILORAMA_MACOSCONTROLLER_H


#include <QObject>
#include <QString>

class QQmlEngine;

class MacOSController : public QObject
{
    Q_OBJECT
public:
    explicit MacOSController(QObject *parent = nullptr);
    void setEngine(QQmlEngine *engine);

public slots:
    static void disableAppNap();
    static void showInDock();
    static void hideFromDock();
    static void requestNotificationPermission();

    static void clearScheduledNotifications();

    void scheduleNotification(const QString &title, const QString &message,
                              const QString &iconPath, int seconds) const;

    void showNotification(const QString &title, const QString &message,
                          const QString &iconPath) const;

private:
    QQmlEngine *engine_ = nullptr;
};

#endif //PILORAMA_MACOSCONTROLLER_H
