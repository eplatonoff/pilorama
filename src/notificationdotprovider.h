#ifndef NOTIFICATIONDOTPROVIDER_H
#define NOTIFICATIONDOTPROVIDER_H

#include <QQuickImageProvider>

class NotificationDotProvider : public QQuickImageProvider
{
public:
    NotificationDotProvider();

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // NOTIFICATIONDOTPROVIDER_H