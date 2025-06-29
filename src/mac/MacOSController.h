#ifndef PILORAMA_MACOSCONTROLLER_H
#define PILORAMA_MACOSCONTROLLER_H


#include <QObject>
#include <QString>

class MacOSController : public QObject
{
    Q_OBJECT
public:
    explicit MacOSController(QObject *parent = nullptr);

public slots:
    void disableAppNap();
    void showInDock();
    void hideFromDock();
    void requestNotificationPermission();
    void showNotification(const QString &title, const QString &message,
                          const QString &iconPath);
};

#endif //PILORAMA_MACOSCONTROLLER_H
