#include "MacOSController.h"

#include <QPixmap>
#include <QQmlEngine>
#include <QQuickImageProvider>
#include <QDir>
#include <QUrl>


static QString prepareIconFile(const QString &iconPath, const QQmlEngine *engine)
{
    const QUrl url(iconPath);
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }

    QPixmap pix;

    const QString providerId = url.host();
    if (const auto provider = qobject_cast<QQuickImageProvider*>(engine->imageProvider(providerId))) {
        const QString requestId = url.toString().remove(0, url.toString().indexOf("#"));
        QSize size;
        pix = provider->requestPixmap(requestId, &size, QSize());
    }
    else {
        qWarning() << "Failed to get image provider for:" << providerId;
    }

    if (pix.isNull()) {
        qWarning() << "Failed to load image, returning empty path";
        return {};
    }

    const QString tempFile = QDir::temp().filePath("pilorama_notify_icon.png");
    if (!pix.save(tempFile, "PNG")) {
        qWarning() << "Failed to save image to temp file:" << tempFile;
        return {};
    }
    qDebug() << "Saved image to temp file:" << tempFile;
    return tempFile;
}

#ifdef __APPLE__
#if TARGET_OS_MAC
extern void mac_show_in_dock();
extern void mac_hide_from_dock();
extern void mac_disable_app_nap();
extern void mac_request_notification_permission();
extern void mac_send_notification(const char *title, const char *message,
                                  const char *icon);
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */

MacOSController::MacOSController(QObject *parent) : QObject(parent)
{
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_request_notification_permission();
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}

void MacOSController::setEngine(QQmlEngine* engine) {
    engine_ = engine;
}

void MacOSController::showInDock()
{
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_show_in_dock();
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}

void MacOSController::hideFromDock()
{
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_hide_from_dock();
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}

void MacOSController::disableAppNap() {
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_disable_app_nap();
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}

void MacOSController::requestNotificationPermission()
{
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_request_notification_permission();
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}

void MacOSController::showNotification(const QString &title, const QString &message,
                                       const QString &iconPath) const {
#ifdef __APPLE__
#if TARGET_OS_MAC
    if (engine_ == nullptr) {
        qWarning() << "Engine is not set";
        return;
    }
    const QString iconFile = prepareIconFile(iconPath, engine_);
    mac_send_notification(title.toUtf8().constData(),
                          message.toUtf8().constData(),
                          iconFile.toUtf8().constData());
#else
    Q_UNUSED(title)
    Q_UNUSED(message)
    Q_UNUSED(iconPath)
#endif /* TARGET_OS_MAC */
#else
    Q_UNUSED(title)
    Q_UNUSED(message)
    Q_UNUSED(iconPath)
#endif /* __APPLE__ */
}
