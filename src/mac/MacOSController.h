#ifndef PILORAMA_MACOSCONTROLLER_H
#define PILORAMA_MACOSCONTROLLER_H


#include <QObject>

class MacOSController : public QObject
{
    Q_OBJECT
public:
    explicit MacOSController(QObject *parent = nullptr);

public slots:
    void disableAppNap();
    void showInDock();
    void hideFromDock();
    void showNotification(const QString &title, const QString &message);
};

#endif //PILORAMA_MACOSCONTROLLER_H
