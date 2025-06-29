#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <AppKit/AppKit.h>
#import <UserNotifications/UserNotifications.h>

void mac_disable_app_nap(void)
{
   if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
   {
      [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"Not sleepy and don't want to nap"];
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

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                                                          content:content
                                                                          trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

void mac_clear_scheduled_notifications(void)
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}


