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
    static void beginAppNapActivity();
    static void endAppNapActivity();
    static void showInDock();
    static void hideFromDock();
    static void setShowInDockPreference(bool showInDock);
    static void requestNotificationPermission();

    static void clearScheduledNotifications();
    static void clearStaleScheduledNotifications();

    int scheduleNotification(const QString &title, const QString &message,
                             const QString &iconPath, double seconds, bool playSound);

    void showNotification(const QString &title, const QString &message,
                          const QString &iconPath) const;

signals:
    void notificationScheduleResolved(int requestId, bool success);

private:
    QQmlEngine *engine_ = nullptr;
    int nextScheduleRequestId_ = 0;
};

#endif //PILORAMA_MACOSCONTROLLER_H
