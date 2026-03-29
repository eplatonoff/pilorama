#include <QtTest>

#include <QGuiApplication>
#include <QElapsedTimer>
#include <QScreen>
#include <QWindow>

#import <objc/runtime.h>
#import <UserNotifications/UserNotifications.h>

@interface PiloramaNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

bool mac_schedule_notification(const char *title, const char *message,
                               const char *icon, double seconds,
                               void (*completionCallback)(void *context, bool success),
                               void *context);
void mac_clear_scheduled_notifications(void);
void mac_clear_stale_scheduled_notifications(void);

@interface PiloramaTestNotificationCenter : NSObject
@property(nonatomic) NSInteger addRequestCalls;
@property(nonatomic) NSInteger settingsCalls;
@property(nonatomic) NSInteger pendingRequestsCalls;
@property(nonatomic) NSInteger removePendingCalls;
@property(nonatomic) NSInteger removeDeliveredCalls;
@property(nonatomic) BOOL deferPendingRequestsCompletion;
@property(nonatomic, copy) NSArray<NSString *> *lastPendingIdentifiers;
@property(nonatomic, copy) NSArray<NSString *> *lastDeliveredIdentifiers;
@property(nonatomic, strong) NSMutableArray<NSString *> *addedIdentifiers;
@property(nonatomic, strong) NSMutableArray<NSString *> *pendingIdentifiers;
@property(nonatomic, strong) NSMutableArray *completionHandlers;
@property(nonatomic, strong) NSMutableArray *pendingRequestsCompletionHandlers;
+ (instancetype)sharedCenter;
+ (id)stubCurrentNotificationCenter;
- (void)reset;
- (void)completeRequestAtIndex:(NSInteger)index error:(NSError *)error;
- (void)completePendingRequestsQueryAtIndex:(NSInteger)index;
- (NSString *)addedIdentifierAtIndex:(NSInteger)index;
@end

@implementation PiloramaTestNotificationCenter
+ (instancetype)sharedCenter
{
    static PiloramaTestNotificationCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [PiloramaTestNotificationCenter new];
    });
    return center;
}

+ (id)stubCurrentNotificationCenter
{
    return [PiloramaTestNotificationCenter sharedCenter];
}

- (void)reset
{
    self.addRequestCalls = 0;
    self.settingsCalls = 0;
    self.pendingRequestsCalls = 0;
    self.removePendingCalls = 0;
    self.removeDeliveredCalls = 0;
    self.deferPendingRequestsCompletion = NO;
    self.lastPendingIdentifiers = nil;
    self.lastDeliveredIdentifiers = nil;
    self.addedIdentifiers = [NSMutableArray array];
    self.pendingIdentifiers = [NSMutableArray array];
    self.completionHandlers = [NSMutableArray array];
    self.pendingRequestsCompletionHandlers = [NSMutableArray array];
}

- (void)getNotificationSettingsWithCompletionHandler:(void (^)(UNNotificationSettings *settings))completionHandler
{
    Q_UNUSED(completionHandler);
    ++self.settingsCalls;
}

- (void)addNotificationRequest:(UNNotificationRequest *)request
         withCompletionHandler:(void (^)(NSError *error))completionHandler
{
    ++self.addRequestCalls;
    [self.addedIdentifiers addObject:request.identifier ?: @""];
    [self.pendingIdentifiers addObject:request.identifier ?: @""];
    [self.completionHandlers addObject:completionHandler ? [completionHandler copy] : [NSNull null]];
}

- (void)getPendingNotificationRequestsWithCompletionHandler:
    (void (^)(NSArray<UNNotificationRequest *> *requests))completionHandler
{
    ++self.pendingRequestsCalls;

    if (self.deferPendingRequestsCompletion) {
        [self.pendingRequestsCompletionHandlers addObject:completionHandler
                                                       ? [completionHandler copy]
                                                       : [NSNull null]];
        return;
    }

    NSMutableArray<UNNotificationRequest *> *requests =
        [NSMutableArray arrayWithCapacity:self.pendingIdentifiers.count];
    for (NSString *identifier in self.pendingIdentifiers) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        [requests addObject:[UNNotificationRequest requestWithIdentifier:identifier
                                                                 content:content
                                                                 trigger:nil]];
    }

    if (completionHandler)
        completionHandler([requests copy]);
}

- (void)removePendingNotificationRequestsWithIdentifiers:(NSArray<NSString *> *)identifiers
{
    ++self.removePendingCalls;
    self.lastPendingIdentifiers = [identifiers copy];
    if (identifiers.count > 0)
        [self.pendingIdentifiers removeObjectsInArray:identifiers];
}

- (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers
{
    ++self.removeDeliveredCalls;
    self.lastDeliveredIdentifiers = [identifiers copy];
}

- (void)completeRequestAtIndex:(NSInteger)index error:(NSError *)error
{
    if (index < 0 || index >= self.completionHandlers.count)
        return;

    id handler = self.completionHandlers[index];
    if ([handler isKindOfClass:[NSNull class]])
        return;

    void (^completionHandler)(NSError *) = handler;
    completionHandler(error);
}

- (void)completePendingRequestsQueryAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.pendingRequestsCompletionHandlers.count)
        return;

    id handler = self.pendingRequestsCompletionHandlers[index];
    if ([handler isKindOfClass:[NSNull class]])
        return;

    NSMutableArray<UNNotificationRequest *> *requests =
        [NSMutableArray arrayWithCapacity:self.pendingIdentifiers.count];
    for (NSString *identifier in self.pendingIdentifiers) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        [requests addObject:[UNNotificationRequest requestWithIdentifier:identifier
                                                                 content:content
                                                                 trigger:nil]];
    }

    self.pendingRequestsCompletionHandlers[index] = [NSNull null];

    void (^completionHandler)(NSArray<UNNotificationRequest *> *) = handler;
    completionHandler([requests copy]);
}

- (NSString *)addedIdentifierAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.addedIdentifiers.count)
        return nil;
    return self.addedIdentifiers[index];
}
@end

namespace {

struct ScopedMethodExchange {
    Method first = nullptr;
    Method second = nullptr;

    ScopedMethodExchange(Method firstMethod, Method secondMethod)
        : first(firstMethod), second(secondMethod)
    {
        method_exchangeImplementations(first, second);
    }

    ~ScopedMethodExchange()
    {
        method_exchangeImplementations(first, second);
    }
};

struct ScheduleCallbackResult {
    bool called = false;
    bool success = true;
};

void storeScheduleCallbackResult(void *context, bool success)
{
    if (!context)
        return;

    auto *result = static_cast<ScheduleCallbackResult *>(context);
    result->called = true;
    result->success = success;
}

} // namespace

class PiloramaReviewMacOSTests final : public QObject
{
    Q_OBJECT

private slots:
    void scheduleNotificationReturnsBeforeAsyncCallbacksFinish()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);

        QElapsedTimer timer;
        timer.start();
        const bool scheduled = mac_schedule_notification("Title", "Body", "", 60.0, nullptr,
                                                         nullptr);
        const qint64 elapsedMs = timer.elapsed();

        QVERIFY2(scheduled,
                 "scheduleNotification should accept the request without waiting for callbacks");
        QVERIFY2(elapsedMs < 100,
                 "scheduleNotification should return immediately instead of blocking the GUI thread");
        QCOMPARE(center.addRequestCalls, 1);
        QCOMPARE(center.settingsCalls, 1);
    }

    void clearScheduledNotificationsLeavesDeliveredAlertsIntact()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);
        const bool scheduled = mac_schedule_notification("Title", "Body", "", 60.0, nullptr,
                                                         nullptr);
        QVERIFY(scheduled);
        mac_clear_scheduled_notifications();

        QCOMPARE(center.removePendingCalls, 1);
        QCOMPARE(center.removeDeliveredCalls, 0);
        QCOMPARE(center.lastPendingIdentifiers.count, 1);
        QVERIFY([center.lastPendingIdentifiers[0] hasPrefix:@"pilorama.scheduled"]);
        QVERIFY(center.lastDeliveredIdentifiers == nil);
    }

    void clearStaleScheduledNotificationsRemovesPendingRequestsFromPreviousRun()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];
        [center.pendingIdentifiers addObject:@"pilorama.scheduled.41"];
        [center.pendingIdentifiers addObject:@"third.party.notification"];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);
        mac_clear_stale_scheduled_notifications();

        QCOMPARE(center.pendingRequestsCalls, 1);
        QCOMPARE(center.removePendingCalls, 1);
        QCOMPARE(center.removeDeliveredCalls, 0);
        QCOMPARE(center.lastPendingIdentifiers.count, 1);
        QCOMPARE(center.lastPendingIdentifiers[0], @"pilorama.scheduled.41");
        QVERIFY(![center.pendingIdentifiers containsObject:@"pilorama.scheduled.41"]);
        QVERIFY([center.pendingIdentifiers containsObject:@"third.party.notification"]);
    }

    void delayedStartupSweepLeavesNewlyScheduledNotificationIntact()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];
        center.deferPendingRequestsCompletion = YES;
        [center.pendingIdentifiers addObject:@"pilorama.scheduled.41"];
        [center.pendingIdentifiers addObject:@"third.party.notification"];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);

        mac_clear_stale_scheduled_notifications();
        QVERIFY(mac_schedule_notification("Fresh", "Body", "", 120.0, nullptr, nullptr));
        NSString *freshIdentifier = [center addedIdentifierAtIndex:0];
        QVERIFY(freshIdentifier != nil);

        [center completePendingRequestsQueryAtIndex:0];

        QVERIFY(![center.pendingIdentifiers containsObject:@"pilorama.scheduled.41"]);
        QVERIFY([center.pendingIdentifiers containsObject:@"third.party.notification"]);
        QVERIFY2([center.pendingIdentifiers containsObject:freshIdentifier],
                 "startup stale sweep should not remove the current run's notification");
    }

    void staleAsyncScheduleIsCancelledAfterClear()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);

        ScheduleCallbackResult callbackResult;
        const bool scheduled = mac_schedule_notification("Title", "Body", "", 60.0,
                                                         storeScheduleCallbackResult,
                                                         &callbackResult);
        QVERIFY(scheduled);
        QCOMPARE(center.addRequestCalls, 1);

        mac_clear_scheduled_notifications();
        QCOMPARE(center.removePendingCalls, 1);

        [center completeRequestAtIndex:0 error:nil];

        QVERIFY(callbackResult.called);
        QVERIFY(!callbackResult.success);
        QCOMPARE(center.removePendingCalls, 2);
        QCOMPARE(center.lastPendingIdentifiers.count, 1);
        QVERIFY([center.lastPendingIdentifiers[0] hasPrefix:@"pilorama.scheduled"]);
    }

    void staleAsyncCompletionDoesNotRemoveNewerSchedule()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];

        const ScopedMethodExchange exchange(currentMethod, stubMethod);

        ScheduleCallbackResult firstResult;
        ScheduleCallbackResult secondResult;
        QVERIFY(mac_schedule_notification("First", "Body", "", 60.0,
                                          storeScheduleCallbackResult, &firstResult));
        NSString *firstIdentifier = [center addedIdentifierAtIndex:0];
        QVERIFY(firstIdentifier != nil);

        mac_clear_scheduled_notifications();

        QVERIFY(mac_schedule_notification("Second", "Body", "", 120.0,
                                          storeScheduleCallbackResult, &secondResult));
        NSString *secondIdentifier = [center addedIdentifierAtIndex:1];
        QVERIFY(secondIdentifier != nil);
        QVERIFY(firstIdentifier != secondIdentifier);

        [center completeRequestAtIndex:0 error:nil];

        QVERIFY(firstResult.called);
        QVERIFY(!firstResult.success);
        QVERIFY(!secondResult.called);
        QCOMPARE(center.removePendingCalls, 2);
        QCOMPARE(center.lastPendingIdentifiers.count, 1);
        QVERIFY([center.lastPendingIdentifiers isEqualToArray:@[ firstIdentifier ]]);

        [center completeRequestAtIndex:1 error:nil];

        QVERIFY(secondResult.called);
        QVERIFY(secondResult.success);
        QCOMPARE(center.removePendingCalls, 2);
    }

    void delayedPendingSweepDoesNotRemoveReplacementSchedule()
    {
        Method currentMethod = class_getClassMethod([UNUserNotificationCenter class],
                                                    @selector(currentNotificationCenter));
        Method stubMethod = class_getClassMethod([PiloramaTestNotificationCenter class],
                                                 @selector(stubCurrentNotificationCenter));
        QVERIFY(currentMethod != nullptr);
        QVERIFY(stubMethod != nullptr);

        PiloramaTestNotificationCenter *center = [PiloramaTestNotificationCenter sharedCenter];
        [center reset];
        center.deferPendingRequestsCompletion = YES;

        const ScopedMethodExchange exchange(currentMethod, stubMethod);

        QVERIFY(mac_schedule_notification("First", "Body", "", 60.0, nullptr, nullptr));
        NSString *firstIdentifier = [center addedIdentifierAtIndex:0];
        QVERIFY(firstIdentifier != nil);

        mac_clear_scheduled_notifications();
        QVERIFY(![center.pendingIdentifiers containsObject:firstIdentifier]);

        QVERIFY(mac_schedule_notification("Second", "Body", "", 120.0, nullptr, nullptr));
        NSString *secondIdentifier = [center addedIdentifierAtIndex:1];
        QVERIFY(secondIdentifier != nil);

        [center completePendingRequestsQueryAtIndex:0];

        QVERIFY([center.pendingIdentifiers containsObject:secondIdentifier]);
    }

    void notificationClickReopensHiddenWindow()
    {
        const QString platformName = QGuiApplication::platformName();
        if (QGuiApplication::screens().isEmpty()
            || platformName == QStringLiteral("offscreen")
            || platformName == QStringLiteral("minimal")) {
            QSKIP("Requires a window-capable GUI environment");
        }

        QWindow window;
        window.setTitle(QStringLiteral("Pilorama review test window"));

        window.show();
        QTRY_VERIFY(window.isVisible());

        window.hide();
        QTRY_VERIFY(!window.isVisible());

        auto *delegate = [PiloramaNotificationDelegate new];
        __block bool completionCalled = false;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        [delegate userNotificationCenter:nil
             didReceiveNotificationResponse:nil
                      withCompletionHandler:^{
                          completionCalled = true;
                      }];
#pragma clang diagnostic pop

        QVERIFY(completionCalled);
        QTRY_VERIFY(window.isVisible());
    }
};

std::unique_ptr<QObject> createMacOsReviewMacOSTests()
{
    return std::make_unique<PiloramaReviewMacOSTests>();
}

#include "pilorama_review_macos_tests.moc"
