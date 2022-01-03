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


