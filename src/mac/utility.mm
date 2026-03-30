#include <QGuiApplication>
#include <QDebug>
#include <QWindow>

#include <atomic>

#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <AppKit/AppKit.h>
#import <UserNotifications/UserNotifications.h>

static NSString *const kPiloramaScheduledNotificationIdPrefix = @"pilorama.scheduled";
static id appNapActivity = nil;
static id notificationDelegate = nil;
static std::atomic<int> piloramaNotificationAuthorizationStatus{
    static_cast<int>(UNAuthorizationStatusNotDetermined)
};
static std::atomic<unsigned long long> piloramaNextScheduledNotificationToken{0};
static std::atomic<unsigned long long> piloramaCurrentScheduledNotificationToken{0};
static std::atomic<unsigned long long> piloramaConfirmedScheduledNotificationToken{0};
static std::atomic<bool> piloramaShowInDockPreference{false};
using PiloramaScheduleNotificationCallback = void (*)(void *context, bool success);

void mac_show_in_dock(void);

static NSString *pilorama_scheduled_notification_identifier(unsigned long long token)
{
    if (token == 0)
        return nil;

    return [NSString stringWithFormat:@"%@.%llu", kPiloramaScheduledNotificationIdPrefix, token];
}

static void pilorama_remove_pending_notification(NSString *identifier)
{
    if (!identifier || identifier.length == 0)
        return;

    [[UNUserNotificationCenter currentNotificationCenter]
        removePendingNotificationRequestsWithIdentifiers:@[ identifier ]];
}

static void pilorama_remove_pending_notification_for_token(unsigned long long token)
{
    pilorama_remove_pending_notification(pilorama_scheduled_notification_identifier(token));
}

static bool pilorama_is_scheduled_notification_identifier(NSString *identifier)
{
    return identifier && [identifier hasPrefix:kPiloramaScheduledNotificationIdPrefix];
}

static void pilorama_remove_all_pending_scheduled_notifications(void)
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(
         NSArray<UNNotificationRequest *> *requests) {
        NSString *currentIdentifier = pilorama_scheduled_notification_identifier(
            piloramaCurrentScheduledNotificationToken.load(std::memory_order_relaxed));
        NSString *confirmedIdentifier = pilorama_scheduled_notification_identifier(
            piloramaConfirmedScheduledNotificationToken.load(std::memory_order_relaxed));
        NSMutableArray<NSString *> *identifiers = [NSMutableArray array];
        for (UNNotificationRequest *request in requests) {
            if (!pilorama_is_scheduled_notification_identifier(request.identifier))
                continue;
            if (currentIdentifier && [request.identifier isEqualToString:currentIdentifier])
                continue;
            if (confirmedIdentifier && [request.identifier isEqualToString:confirmedIdentifier])
                continue;
            [identifiers addObject:request.identifier];
        }
        if (identifiers.count > 0) {
            [center removePendingNotificationRequestsWithIdentifiers:[identifiers copy]];
        }
    }];
}

static void pilorama_reopen_window(void)
{
    const auto windows = QGuiApplication::topLevelWindows();
    for (QWindow *window : windows) {
        if (!window)
            continue;
        window->show();
        window->raise();
        window->requestActivate();
        return;
    }

    for (NSWindow *window in [NSApp windows]) {
        [window makeKeyAndOrderFront:nil];
        break;
    }
}

@interface PiloramaNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

@implementation PiloramaNotificationDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    Q_UNUSED(center);
    Q_UNUSED(notification);

    UNNotificationPresentationOptions options = 0;
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 110000
    if (@available(macOS 11.0, *)) {
        options = UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        options = UNNotificationPresentationOptionAlert;
#pragma clang diagnostic pop
    }
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    options = UNNotificationPresentationOptionAlert;
#pragma clang diagnostic pop
#endif

    if (notification.request.content.sound != nil)
        options |= UNNotificationPresentationOptionSound;

    if (completionHandler)
        completionHandler(options);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (piloramaShowInDockPreference.load(std::memory_order_relaxed))
            mac_show_in_dock();
        [NSApp unhide:nil];
        [NSApp activateIgnoringOtherApps:YES];
        pilorama_reopen_window();
    });

    if (completionHandler)
        completionHandler();
}
@end

static UNMutableNotificationContent *pilorama_notification_content(const char *title,
                                                                   const char *message,
                                                                   const char *icon,
                                                                   bool playSound = false)
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithUTF8String:title];
    content.body = [NSString stringWithUTF8String:message];
    if (playSound)
        content.sound = [UNNotificationSound defaultSound];

    if (icon && strlen(icon) > 0) {
        NSString *iconPath = [NSString stringWithUTF8String:icon];
        NSURL *url = nil;
        if ([iconPath hasPrefix:@"file://"]) {
            url = [NSURL URLWithString:iconPath];
        } else if ([iconPath hasPrefix:@"/"]) {
            url = [NSURL fileURLWithPath:iconPath];
        } else {
            url = [NSURL URLWithString:iconPath];
        }

        if (url && [url isFileURL]) {
            NSError *attachError = nil;
            UNNotificationAttachment *attachment =
                [UNNotificationAttachment attachmentWithIdentifier:@"icon"
                                                             URL:url
                                                         options:nil
                                                           error:&attachError];
            if (!attachError && attachment) {
                content.attachments = @[ attachment ];
            }
        }
    }

    return content;
}

static UNAuthorizationStatus pilorama_cached_notification_authorization_status(void)
{
    return static_cast<UNAuthorizationStatus>(
        piloramaNotificationAuthorizationStatus.load(std::memory_order_relaxed));
}

static bool pilorama_notification_authorization_is_granted(UNAuthorizationStatus status)
{
    return status != UNAuthorizationStatusDenied
        && status != UNAuthorizationStatusNotDetermined;
}

static void pilorama_store_notification_authorization_status(UNAuthorizationStatus status)
{
    piloramaNotificationAuthorizationStatus.store(static_cast<int>(status),
                                                  std::memory_order_relaxed);
}

void mac_set_notification_authorization_status_for_tests(int status)
{
    pilorama_store_notification_authorization_status(
        static_cast<UNAuthorizationStatus>(status));
}

static void pilorama_refresh_notification_authorization_status(void)
{
    [[UNUserNotificationCenter currentNotificationCenter]
        getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings) {
                pilorama_store_notification_authorization_status(settings.authorizationStatus);
            }
        }];
}

void mac_begin_app_nap_activity(void)
{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
    {
        if (appNapActivity)
            return;
        appNapActivity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF
                                                                        reason:@"Pilorama timer running"];
    }
}

void mac_end_app_nap_activity(void)
{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
    {
        if (!appNapActivity)
            return;
        [[NSProcessInfo processInfo] endActivity:appNapActivity];
        appNapActivity = nil;
    }
}


void mac_hide_from_dock(void) {
   [NSApp setActivationPolicy: NSApplicationActivationPolicyAccessory];
}

void mac_show_in_dock(void) {
    [NSApp setActivationPolicy: NSApplicationActivationPolicyRegular];
}

void mac_set_show_in_dock_preference(bool showInDock)
{
    piloramaShowInDockPreference.store(showInDock, std::memory_order_relaxed);
}

void mac_request_notification_permission(void)
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (!notificationDelegate) {
        notificationDelegate = [[PiloramaNotificationDelegate alloc] init];
    }
    center.delegate = notificationDelegate;
    pilorama_refresh_notification_authorization_status();
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (granted) {
                                  pilorama_store_notification_authorization_status(
                                      UNAuthorizationStatusAuthorized);
                              } else if (!error) {
                                  pilorama_store_notification_authorization_status(
                                      UNAuthorizationStatusDenied);
                              }
                              pilorama_refresh_notification_authorization_status();
                          }];
}

void mac_send_notification(const char *title, const char *message,
                           const char *icon)
{
    UNMutableNotificationContent *content =
        pilorama_notification_content(title, message, icon, false);

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                                                          content:content
                                                                          trigger:nil];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

bool mac_schedule_notification(const char *title, const char *message,
                               const char *icon, double seconds,
                               PiloramaScheduleNotificationCallback completionCallback,
                               void *context, bool playSound)
{
    const UNAuthorizationStatus cachedStatus = pilorama_cached_notification_authorization_status();
    if (!pilorama_notification_authorization_is_granted(cachedStatus)) {
        qWarning() << "macOS notifications are not authorized yet; skipping scheduled notification";
        pilorama_refresh_notification_authorization_status();
        return false;
    }

    UNMutableNotificationContent *content =
        pilorama_notification_content(title, message, icon, playSound);
    const unsigned long long token =
        piloramaNextScheduledNotificationToken.fetch_add(1, std::memory_order_relaxed) + 1;
    piloramaCurrentScheduledNotificationToken.store(token, std::memory_order_relaxed);
    NSString *identifier = pilorama_scheduled_notification_identifier(token);

    UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:seconds repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content
                                                                          trigger:trigger];

    pilorama_refresh_notification_authorization_status();
    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request
         withCompletionHandler:^(NSError * _Nullable error) {
             const bool isCurrentRequest =
                 piloramaCurrentScheduledNotificationToken.load(std::memory_order_relaxed) == token;
             if (error) {
                 qWarning() << "Failed to schedule macOS notification:"
                            << error.localizedDescription.UTF8String;
                 pilorama_refresh_notification_authorization_status();
                 if (isCurrentRequest) {
                     const unsigned long long fallbackToken =
                         piloramaConfirmedScheduledNotificationToken.load(
                             std::memory_order_relaxed);
                     unsigned long long expectedToken = token;
                     piloramaCurrentScheduledNotificationToken.compare_exchange_strong(
                         expectedToken, fallbackToken, std::memory_order_relaxed);
                 }
             } else if (!isCurrentRequest) {
                 pilorama_remove_pending_notification_for_token(token);
             } else {
                 const unsigned long long previousConfirmedToken =
                     piloramaConfirmedScheduledNotificationToken.exchange(
                         token, std::memory_order_relaxed);
                 if (previousConfirmedToken != 0 && previousConfirmedToken != token) {
                     pilorama_remove_pending_notification_for_token(previousConfirmedToken);
                 }
             }
             if (completionCallback) {
                 completionCallback(context, error == nil && isCurrentRequest);
             }
         }];

    return true;
}

void mac_clear_scheduled_notifications(void)
{
    const unsigned long long currentToken =
        piloramaCurrentScheduledNotificationToken.exchange(0, std::memory_order_relaxed);
    const unsigned long long confirmedToken =
        piloramaConfirmedScheduledNotificationToken.exchange(0, std::memory_order_relaxed);
    pilorama_remove_pending_notification_for_token(currentToken);
    if (confirmedToken != 0 && confirmedToken != currentToken)
        pilorama_remove_pending_notification_for_token(confirmedToken);
}

void mac_clear_stale_scheduled_notifications(void)
{
    pilorama_remove_all_pending_scheduled_notifications();
}
