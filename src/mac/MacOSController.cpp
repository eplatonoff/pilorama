#include "MacOSController.h"

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
                                       const QString &iconPath)
{
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_send_notification(title.toUtf8().constData(),
                          message.toUtf8().constData(),
                          iconPath.toUtf8().constData());
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
