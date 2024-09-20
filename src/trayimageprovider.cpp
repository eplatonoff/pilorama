#include "trayimageprovider.h"

#include <QPainter>
#include <QPainterPath>

TrayImageProvider::TrayImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{

}


QPixmap TrayImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QStringList colorInfo = id.split("_");
    Q_ASSERT(colorInfo.size() == 3);

    bool ok = false;

    const auto secs = colorInfo[2].toInt(&ok);
    Q_ASSERT(ok);

    const auto color = QColor(colorInfo[0]);
    Q_ASSERT(color.isValid());

    const auto placeholderColor = QColor(colorInfo[1]);
    Q_ASSERT(color.isValid());

    constexpr int width = 320, height = 320;
    constexpr int hPadding = 30, vPadding = 30;
    constexpr int penWidth = 48;

    QPoint startPoint(width / 2, vPadding);

    QPixmap pix(width, height);
    pix.fill(Qt::transparent);

    // Placeholder wheel

    QPainter placeholder(&pix);
    placeholder.setPen( { QBrush(placeholderColor), penWidth } );

    QPainterPath placeholderPath;
    placeholderPath.moveTo(startPoint);
    placeholderPath.arcTo(
        hPadding,
        vPadding,
        width - 2 * hPadding,
        height - 2 * vPadding,
        90, // start angle
        450 // clock-wise
    );

    placeholder.drawPath(placeholderPath);

    placeholder.end();

    // Timer wheel

    QPainter painter(&pix);
    painter.setPen( { QBrush(color), penWidth } );

    QPainterPath path;
    path.moveTo(startPoint);
    path.arcTo(
        hPadding,
        vPadding,
        width - 2 * hPadding,
        height - 2 * vPadding,
        90, // start angle
        secs * -1.0 / 10 // clock-wise
    );

    painter.drawPath(path);

    painter.end();

    return pix;
}
