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

void mac_send_notification(const char *title, const char *message)
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithUTF8String:title];
    content.body = [NSString stringWithUTF8String:message];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                                                          content:content
                                                                          trigger:nil];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}


