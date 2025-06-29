#include "notificationdotprovider.h"
#include <QPainter>

NotificationDotProvider::NotificationDotProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap NotificationDotProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    const QColor color(id);
    if (!color.isValid()) {
        qWarning() << "Invalid color:" << id;
        return {};
    }

    constexpr int width = 100, height = 100;
    constexpr int dotSize = 50;

    if (size)
        *size = QSize(width, height);

    QPixmap pix(width, height);
    pix.fill(Qt::transparent);

    QPainter painter(&pix);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setBrush(color);
    painter.setPen(Qt::NoPen);
    constexpr int offsetX = (width - dotSize) / 2;
    constexpr int offsetY = (height - dotSize) / 2;
    painter.drawRoundedRect(offsetX, offsetY, dotSize, dotSize, dotSize / 2, dotSize / 2);
    painter.end();

    return pix;
}