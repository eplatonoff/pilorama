#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <AppKit/AppKit.h>

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

void mac_send_notification(const char *title, const char *message) {
    if (@available(macOS 10.8, *)) {
        NSString *titleStr = [NSString stringWithUTF8String:title];
        NSString *messageStr = message ? [NSString stringWithUTF8String:message] : @"";

        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = titleStr;
        notification.informativeText = messageStr;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
#if !__has_feature(objc_arc)
        [notification release];
#endif
    }
}



