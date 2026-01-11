#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <AppKit/AppKit.h>
#import <UserNotifications/UserNotifications.h>

static NSString *const kPiloramaScheduledNotificationId = @"pilorama.scheduled";
static id appNapActivity = nil;
static id notificationDelegate = nil;

@interface PiloramaNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

@implementation PiloramaNotificationDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp unhide:nil];
        [NSApp activateIgnoringOtherApps:YES];
        for (NSWindow *window in [NSApp windows]) {
            if ([window isVisible]) {
                [window makeKeyAndOrderFront:nil];
                break;
            }
        }
    });

    if (completionHandler)
        completionHandler();
}
@end

void mac_disable_app_nap(void)
{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
    {
        [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"Not sleepy and don't want to nap"];
    }

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

void mac_request_notification_permission(void)
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (!notificationDelegate) {
        notificationDelegate = [[PiloramaNotificationDelegate alloc] init];
    }
    center.delegate = notificationDelegate;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              
                          }];
}

void mac_send_notification(const char *title, const char *message,
                           const char *icon)
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithUTF8String:title];
    content.body = [NSString stringWithUTF8String:message];

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

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                                                          content:content
                                                                          trigger:nil];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

void mac_schedule_notification(const char *title, const char *message,
                               const char *icon, double seconds)
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithUTF8String:title];
    content.body = [NSString stringWithUTF8String:message];

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

    UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:seconds repeats:NO];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:kPiloramaScheduledNotificationId
                                                                          content:content
                                                                          trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

void mac_clear_scheduled_notifications(void)
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
    [center removeDeliveredNotificationsWithIdentifiers:@[kPiloramaScheduledNotificationId]];
}
