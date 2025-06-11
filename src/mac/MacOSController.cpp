#include "MacOSController.h"

#ifdef __APPLE__
#if TARGET_OS_MAC
extern void mac_show_in_dock();
extern void mac_hide_from_dock();
extern void mac_disable_app_nap();
extern void mac_send_notification(const char *title, const char *message);
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */

MacOSController::MacOSController(QObject *parent) : QObject(parent)
{
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

void MacOSController::showNotification(const QString &title, const QString &message) {
#ifdef __APPLE__
#if TARGET_OS_MAC
    mac_send_notification(title.toUtf8().constData(), message.toUtf8().constData());
#endif /* TARGET_OS_MAC */
#endif /* __APPLE__ */
}
