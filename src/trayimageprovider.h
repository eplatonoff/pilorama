#ifndef TRAYIMAGEPROVIDER_H
#define TRAYIMAGEPROVIDER_H

#include <QQuickImageProvider>


class TrayImageProvider final : public QQuickImageProvider
{
public:
    TrayImageProvider();

    QPixmap requestPixmap(const QString& id, QSize* size, const QSize& requestedSize) override;
};

#endif // TRAYIMAGEPROVIDER_H
