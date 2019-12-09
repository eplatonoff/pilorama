#include "trayimageprovider.h"

#include <QPainter>
#include <QDebug>

TrayImageProvider::TrayImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{

}


QPixmap TrayImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QStringList colorInfo = id.split("_");
    Q_ASSERT(colorInfo.size() == 2);

    bool ok = false;

    const auto secs = colorInfo[1].toInt(&ok);
    Q_ASSERT(ok);

    const auto color = QColor(colorInfo[0]);
    Q_ASSERT(color.isValid());

    const int width = 320, height = 320;
    const int hPadding = 30, vPadding = 30;
    const int penWidth = 40;

    QPoint startPoint(width / 2, vPadding);

    QPixmap pix(width, height);
    pix.fill(Qt::transparent);

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
        - secs / 10 // clock-wise
    );

    painter.drawPath(path);

    painter.end();

    return pix;
}
