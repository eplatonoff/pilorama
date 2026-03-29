#include <QtTest>

#include <QWindow>

#import <UserNotifications/UserNotifications.h>

@interface PiloramaNotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

class PiloramaReviewMacOSTests final : public QObject
{
    Q_OBJECT

private slots:
    void notificationClickReopensHiddenWindow()
    {
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
