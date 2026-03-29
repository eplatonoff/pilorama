#include <QtTest>

#include <QDateTime>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>

#include "piloramatimer.h"
#include "mac/MacOSController.h"

namespace {

struct Segment {
    int id = -1;
    double duration = 0.0;
    double total = 0.0;
    int key = -1;
};

QVariantMap toVariantMap(const Segment &segment)
{
    QVariantMap item;
    item.insert(QStringLiteral("id"), segment.id);
    item.insert(QStringLiteral("duration"), segment.duration);
    item.insert(QStringLiteral("total"), segment.total);
    item.insert(QStringLiteral("key"), segment.key);
    return item;
}

class MockNotifications final : public QObject
{
    Q_OBJECT

public:
    int scheduleCalls = 0;
    int clearCalls = 0;
    int sendFromItemCalls = 0;
    QVariantMap lastItem;

    Q_INVOKABLE void clearScheduled() { ++clearCalls; }
    Q_INVOKABLE void scheduleNextSegment() { ++scheduleCalls; }
    Q_INVOKABLE void sendFromItem(const QVariant &item)
    {
        ++sendFromItemCalls;
        lastItem = item.toMap();
    }
    Q_INVOKABLE void sendWithSound(const QVariant & = QVariant()) {}
    Q_INVOKABLE void stopSound() {}
};

class MockQueue final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool infiniteMode MEMBER infiniteMode CONSTANT)

public:
    bool infiniteMode = false;

    void setItems(std::initializer_list<Segment> newItems)
    {
        items = QVector<Segment>(newItems.begin(), newItems.end());
    }

    Q_INVOKABLE QVariant first() const
    {
        if (items.isEmpty())
            return {};
        return toVariantMap(items.first());
    }

    Q_INVOKABLE void clear()
    {
        items.clear();
    }

    Q_INVOKABLE void drainTime(double secs)
    {
        if (secs <= 0 || items.isEmpty())
            return;

        double secsToDrain = secs;
        while (secsToDrain > 0.0 && !items.isEmpty()) {
            items[0].duration -= secsToDrain;
            if (items[0].duration <= 0.0) {
                secsToDrain = std::abs(items[0].duration);
                items.removeFirst();
            } else {
                secsToDrain = 0.0;
            }
        }
    }

private:
    QVector<Segment> items;
};

class MockPreferences final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool splitToSequence MEMBER splitToSequence CONSTANT)

public:
    bool splitToSequence = false;
};

class MockWindow final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString clockMode MEMBER clockMode)

public:
    QString clockMode = QStringLiteral("timer");
    int checkClockModeCalls = 0;

    Q_INVOKABLE void checkClockMode() { ++checkClockModeCalls; }
};

class MockMouseArea final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double _prevAngle MEMBER prevAngle)
    Q_PROPERTY(double _totalRotatedSecs MEMBER totalRotatedSecs)

public:
    double prevAngle = 0.0;
    double totalRotatedSecs = 0.0;
};

class MockSequence final : public QObject
{
    Q_OBJECT

public:
    int setCurrentItemCalls = 0;
    QVariant lastCurrentItem;

    Q_INVOKABLE void setCurrentItem()
    {
        ++setCurrentItemCalls;
        lastCurrentItem.clear();
    }

    Q_INVOKABLE void setCurrentItem(const QVariant &item)
    {
        ++setCurrentItemCalls;
        lastCurrentItem = item;
    }
};

class MockCanvas final : public QObject
{
    Q_OBJECT

public:
    int requestPaintCalls = 0;

    Q_INVOKABLE void requestPaint() { ++requestPaintCalls; }
};

class MockTime final : public QObject
{
    Q_OBJECT

public:
    int updateTimeCalls = 0;

    Q_INVOKABLE void updateTime() { ++updateTimeCalls; }
};

class MockMacOSController final : public QObject
{
    Q_OBJECT

public:
    int beginCalls = 0;
    int endCalls = 0;

    Q_INVOKABLE void beginAppNapActivity() { ++beginCalls; }
    Q_INVOKABLE void endAppNapActivity() { ++endCalls; }
};

struct TimerFixture {
    QQmlEngine engine;
    MockNotifications notifications;
    MockQueue queue;
    MockPreferences preferences;
    MockWindow window;
    MockMouseArea mouseArea;
    MockSequence sequence;
    MockCanvas canvas;
    MockTime time;
    MockMacOSController macOSController;
    std::unique_ptr<QObject> timer;
};

QString timerQmlPath()
{
    return QStringLiteral(PILORAMA_SOURCE_DIR "/PiloramaTimer.qml");
}

std::unique_ptr<QObject> createTimer(TimerFixture &fixture)
{
    auto *context = fixture.engine.rootContext();
    context->setContextProperty(QStringLiteral("notifications"), &fixture.notifications);
    context->setContextProperty(QStringLiteral("pomodoroQueue"), &fixture.queue);
    context->setContextProperty(QStringLiteral("preferences"), &fixture.preferences);
    context->setContextProperty(QStringLiteral("window"), &fixture.window);
    context->setContextProperty(QStringLiteral("mouseArea"), &fixture.mouseArea);
    context->setContextProperty(QStringLiteral("sequence"), &fixture.sequence);
    context->setContextProperty(QStringLiteral("canvas"), &fixture.canvas);
    context->setContextProperty(QStringLiteral("time"), &fixture.time);
    context->setContextProperty(QStringLiteral("MacOSController"), &fixture.macOSController);

    QQmlComponent component(&fixture.engine, QUrl::fromLocalFile(timerQmlPath()));
    if (component.isError()) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    QObject *object = component.create(context);
    if (!object) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    return std::unique_ptr<QObject>(object);
}

} // namespace

class PiloramaReviewTests final : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        qmlRegisterType<PiloramaTimer>("Pilorama", 1, 0, "Timer");
    }

    void timerStartUsesSharedSchedulingHook()
    {
        TimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.timer->setProperty("remainingTime", 120.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.notifications.scheduleCalls, 1);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "stop"));
    }

    void splitSegmentRolloverSchedulesNextSegment()
    {
        TimerFixture fixture;
        fixture.preferences.splitToSequence = true;
        fixture.queue.setItems({
            Segment{0, 1.0, 1.0, 10},
            Segment{1, 5.0, 5.0, 11},
        });

        fixture.timer = createTimer(fixture);
        fixture.timer->setProperty("remainingTime", 6.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        fixture.timer->setProperty("_lastTickMs", QDateTime::currentMSecsSinceEpoch() - 1200.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 1)));

        QCOMPARE(fixture.notifications.sendFromItemCalls, 1);
        QCOMPARE(fixture.notifications.lastItem.value(QStringLiteral("id")).toInt(), 1);
        QCOMPARE(fixture.notifications.scheduleCalls, 2);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "stop"));
    }

    void macOsScheduleNotificationSlotAcceptsFractionalSeconds()
    {
        bool found = false;
        const QMetaObject &metaObject = MacOSController::staticMetaObject;
        for (int i = metaObject.methodOffset(); i < metaObject.methodCount(); ++i) {
            const QMetaMethod method = metaObject.method(i);
            if (method.name() != QByteArrayLiteral("scheduleNotification"))
                continue;
            if (method.parameterTypes() == QList<QByteArray>{
                    QByteArrayLiteral("QString"),
                    QByteArrayLiteral("QString"),
                    QByteArrayLiteral("QString"),
                    QByteArrayLiteral("double"),
                }) {
                found = true;
                break;
            }
        }

        QVERIFY(found);
    }
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    PiloramaReviewTests tests;
    return QTest::qExec(&tests, argc, argv);
}

#include "pilorama_review_tests.moc"
