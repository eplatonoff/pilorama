#include <QtTest>

#include <QDateTime>
#include <QFile>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QRegularExpression>

#include "piloramatimer.h"
#include "mac/MacOSController.h"

namespace {

struct Segment {
    int id = -1;
    double duration = 0.0;
    double total = 0.0;
    int key = -1;
};

QVariantMap masterItem(int id, const QString &name, double duration)
{
    QVariantMap item;
    item.insert(QStringLiteral("id"), id);
    item.insert(QStringLiteral("name"), name);
    item.insert(QStringLiteral("duration"), duration);
    return item;
}

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
    Q_INVOKABLE bool shouldSuppressCatchUpCompletion(double = 0.0, bool = true) const
    {
        return false;
    }
    Q_INVOKABLE bool shouldSuppressCatchUpSegment(const QVariant &, double = 0.0,
                                                  bool = true) const
    {
        return false;
    }
    Q_INVOKABLE void stopSound() {}
};

class MockQueue final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool infiniteMode MEMBER infiniteMode CONSTANT)

public:
    bool infiniteMode = false;

    void setItems(std::initializer_list<Segment> newItems)
    {
        const int oldCount = items.size();
        items = QVector<Segment>(newItems.begin(), newItems.end());
        if (oldCount != items.size())
            emit countChanged();
    }

    Q_INVOKABLE QVariant first() const
    {
        if (items.isEmpty())
            return {};
        return toVariantMap(items.first());
    }

    Q_INVOKABLE QVariant get(int index) const
    {
        if (index < 0 || index >= items.size())
            return {};
        return toVariantMap(items.at(index));
    }

    int count() const
    {
        return items.size();
    }

    Q_INVOKABLE void clear()
    {
        const int oldCount = items.size();
        items.clear();
        if (oldCount != 0)
            emit countChanged();
    }

    Q_INVOKABLE void drainTime(double secs)
    {
        if (secs <= 0 || items.isEmpty())
            return;

        double secsToDrain = secs;
        const int oldCount = items.size();
        while (secsToDrain > 0.0 && !items.isEmpty()) {
            items[0].duration -= secsToDrain;
            if (items[0].duration <= 0.0) {
                secsToDrain = std::abs(items[0].duration);
                items.removeFirst();
            } else {
                secsToDrain = 0.0;
            }
        }

        if (oldCount != items.size())
            emit countChanged();
    }

signals:
    void countChanged();

private:
    QVector<Segment> items;
};

class MockPreferences final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool splitToSequence READ splitToSequence WRITE setSplitToSequence NOTIFY splitToSequenceChanged)

public:
    bool splitToSequence() const
    {
        return splitToSequence_;
    }

    void setSplitToSequence(bool splitToSequence)
    {
        if (splitToSequence_ == splitToSequence)
            return;
        splitToSequence_ = splitToSequence;
        emit splitToSequenceChanged();
    }

signals:
    void splitToSequenceChanged();

private:
    bool splitToSequence_ = false;
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
    int clearScheduledCalls = 0;
    int scheduleNotificationCalls = 0;
    QString scheduledTitle;
    QString scheduledMessage;
    QString scheduledIconPath;
    double scheduledSeconds = -1.0;
    bool scheduledPlaySound = false;
    bool scheduleNotificationResult = true;
    int nextRequestId = 1;
    int lastRequestId = 0;

    Q_INVOKABLE void beginAppNapActivity() { ++beginCalls; }
    Q_INVOKABLE void endAppNapActivity() { ++endCalls; }
    Q_INVOKABLE void clearScheduledNotifications() { ++clearScheduledCalls; }
    Q_INVOKABLE int scheduleNotification(const QString &title, const QString &message,
                                         const QString &iconPath, double seconds,
                                         bool playSound)
    {
        ++scheduleNotificationCalls;
        scheduledTitle = title;
        scheduledMessage = message;
        scheduledIconPath = iconPath;
        scheduledSeconds = seconds;
        scheduledPlaySound = playSound;
        if (!scheduleNotificationResult)
            return 0;
        lastRequestId = nextRequestId++;
        return lastRequestId;
    }

    Q_INVOKABLE void resolveNotification(int requestId, bool success)
    {
        emit notificationScheduleResolved(requestId, success);
    }

signals:
    void notificationScheduleResolved(int requestId, bool success);
};

class MockNotificationSettings final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool soundMuted READ soundMuted WRITE setSoundMuted NOTIFY soundMutedChanged)
    Q_PROPERTY(bool showOnSegmentStart READ showOnSegmentStart WRITE setShowOnSegmentStart NOTIFY showOnSegmentStartChanged)

public:
    bool soundMuted() const
    {
        return soundMuted_;
    }

    void setSoundMuted(bool soundMuted)
    {
        if (soundMuted_ == soundMuted)
            return;
        soundMuted_ = soundMuted;
        emit soundMutedChanged();
    }

    bool showOnSegmentStart() const
    {
        return showOnSegmentStart_;
    }

    void setShowOnSegmentStart(bool showOnSegmentStart)
    {
        if (showOnSegmentStart_ == showOnSegmentStart)
            return;
        showOnSegmentStart_ = showOnSegmentStart;
        emit showOnSegmentStartChanged();
    }

signals:
    void soundMutedChanged();
    void showOnSegmentStartChanged();

private:
    bool soundMuted_ = false;
    bool showOnSegmentStart_ = false;
};

class MockSoundSettings final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl effectiveSoundPath MEMBER effectiveSoundPath CONSTANT)
    Q_PROPERTY(QUrl defaultSound MEMBER defaultSound CONSTANT)

public:
    QUrl effectiveSoundPath = QUrl(QStringLiteral("file:///tmp/test.wav"));
    QUrl defaultSound = QUrl(QStringLiteral("file:///tmp/test.wav"));
};

class MockTray final : public QObject
{
    Q_OBJECT

public:
    int sendCalls = 0;
    int popUpCalls = 0;
    QString lastName;

    Q_INVOKABLE void send(const QString &name)
    {
        ++sendCalls;
        lastName = name;
    }

    Q_INVOKABLE void popUp()
    {
        ++popUpCalls;
    }

    Q_INVOKABLE QString notificationIconURL() const
    {
        return QStringLiteral("icon://notification");
    }
};

class MockMasterModel final : public QObject
{
    Q_OBJECT

public:
    void setItems(std::initializer_list<QVariantMap> newItems)
    {
        items = QVector<QVariantMap>(newItems.begin(), newItems.end());
    }

    Q_INVOKABLE QVariantMap get(int id) const
    {
        for (const QVariantMap &item : items) {
            if (item.value(QStringLiteral("id")).toInt() == id)
                return item;
        }
        return {};
    }

private:
    QVector<QVariantMap> items;
};

class MockClock final : public QObject
{
    Q_OBJECT

public:
    double lastTimeAfterSecs = -1.0;

    Q_INVOKABLE QVariantMap getTimeAfter(double secs)
    {
        lastTimeAfterSecs = secs;
        return QVariantMap{
            {QStringLiteral("clock"), QStringLiteral("t+%1").arg(qRound64(secs))},
        };
    }
};

class MockTimerState final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running MEMBER running CONSTANT)
    Q_PROPERTY(bool splitMode MEMBER splitMode CONSTANT)
    Q_PROPERTY(double remainingTime MEMBER remainingTime CONSTANT)
    Q_PROPERTY(double segmentTotalDuration MEMBER segmentTotalDuration CONSTANT)
    Q_PROPERTY(double durationBound MEMBER durationBound CONSTANT)

public:
    bool running = false;
    bool splitMode = false;
    double remainingTime = 0.0;
    double segmentTotalDuration = 0.0;
    double durationBound = 0.0;
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

struct NotificationFixture {
    QQmlEngine engine;
    MockNotificationSettings settings;
    MockSoundSettings soundSettings;
    MockTray tray;
    MockMasterModel masterModel;
    MockQueue queue;
    MockClock clock;
    MockTimerState timer;
    MockMacOSController macOSController;
    std::unique_ptr<QObject> notificationSystem;
};

struct IntegratedNotificationTimerFixture {
    QQmlEngine engine;
    MockNotificationSettings settings;
    MockSoundSettings soundSettings;
    MockTray tray;
    MockMasterModel masterModel;
    MockQueue queue;
    MockPreferences preferences;
    MockWindow window;
    MockMouseArea mouseArea;
    MockSequence sequence;
    MockCanvas canvas;
    MockTime time;
    MockClock clock;
    MockMacOSController macOSController;
    std::unique_ptr<QObject> notificationSystem;
    std::unique_ptr<QObject> timer;
};

QString timerQmlPath()
{
    return QStringLiteral(PILORAMA_SOURCE_DIR "/PiloramaTimer.qml");
}

QString notificationSystemQmlPath()
{
    return QStringLiteral(PILORAMA_SOURCE_DIR "/NotificationSystem.qml");
}

QString clockQmlDirPath()
{
    return QStringLiteral(PILORAMA_SOURCE_DIR "/Components/");
}

QString installerPath()
{
    return QStringLiteral(PILORAMA_SOURCE_DIR "/../wndws.iss");
}

std::unique_ptr<QObject> createInlineClock(QQmlEngine &engine, const QString &qmlSource)
{
    QQmlComponent component(&engine);
    component.setData(qmlSource.toUtf8(),
                      QUrl::fromLocalFile(clockQmlDirPath() + QStringLiteral("ClockTest.qml")));
    if (component.isError()) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    QObject *object = component.create(engine.rootContext());
    if (!object) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    return std::unique_ptr<QObject>(object);
}

std::unique_ptr<QObject> createTimer(QQmlEngine &engine, QObject *notificationsObject,
                                     QObject *queueObject, QObject *preferencesObject,
                                     QObject *windowObject, QObject *mouseAreaObject,
                                     QObject *sequenceObject, QObject *canvasObject,
                                     QObject *timeObject, QObject *macOSControllerObject)
{
    auto *context = engine.rootContext();
    context->setContextProperty(QStringLiteral("notifications"), notificationsObject);
    context->setContextProperty(QStringLiteral("pomodoroQueue"), queueObject);
    context->setContextProperty(QStringLiteral("preferences"), preferencesObject);
    context->setContextProperty(QStringLiteral("window"), windowObject);
    context->setContextProperty(QStringLiteral("mouseArea"), mouseAreaObject);
    context->setContextProperty(QStringLiteral("sequence"), sequenceObject);
    context->setContextProperty(QStringLiteral("canvas"), canvasObject);
    context->setContextProperty(QStringLiteral("time"), timeObject);
    context->setContextProperty(QStringLiteral("MacOSController"), macOSControllerObject);

    QQmlComponent component(&engine, QUrl::fromLocalFile(timerQmlPath()));
    if (component.isError()) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    const QVariantMap initialProperties{
        {QStringLiteral("notificationsRef"), QVariant::fromValue(notificationsObject)},
        {QStringLiteral("queueRef"), QVariant::fromValue(queueObject)},
        {QStringLiteral("preferencesRef"), QVariant::fromValue(preferencesObject)},
        {QStringLiteral("windowRef"), QVariant::fromValue(windowObject)},
        {QStringLiteral("mouseAreaRef"), QVariant::fromValue(mouseAreaObject)},
        {QStringLiteral("sequenceRef"), QVariant::fromValue(sequenceObject)},
        {QStringLiteral("canvasRef"), QVariant::fromValue(canvasObject)},
        {QStringLiteral("timeRef"), QVariant::fromValue(timeObject)},
        {QStringLiteral("macOSControllerRef"), QVariant::fromValue(macOSControllerObject)},
    };

    QObject *object = component.createWithInitialProperties(initialProperties, context);
    if (!object) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    return std::unique_ptr<QObject>(object);
}

std::unique_ptr<QObject> createTimer(TimerFixture &fixture)
{
    return createTimer(fixture.engine, &fixture.notifications, &fixture.queue, &fixture.preferences,
                       &fixture.window, &fixture.mouseArea, &fixture.sequence, &fixture.canvas,
                       &fixture.time, &fixture.macOSController);
}

std::unique_ptr<QObject> createTimer(IntegratedNotificationTimerFixture &fixture)
{
    return createTimer(fixture.engine, nullptr, &fixture.queue, &fixture.preferences,
                       &fixture.window, &fixture.mouseArea, &fixture.sequence, &fixture.canvas,
                       &fixture.time, &fixture.macOSController);
}

std::unique_ptr<QObject> createNotificationSystem(QQmlEngine &engine, QObject *settingsObject,
                                                  QObject *soundSettingsObject,
                                                  QObject *trayObject, QObject *masterModelObject,
                                                  QObject *timerObject, QObject *queueObject,
                                                  QObject *clockObject,
                                                  QObject *macOSControllerObject)
{
    QQmlComponent component(&engine, QUrl::fromLocalFile(notificationSystemQmlPath()));
    if (component.isError()) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    const QVariantMap initialProperties{
        {QStringLiteral("settings"), QVariant::fromValue(settingsObject)},
        {QStringLiteral("soundSettings"), QVariant::fromValue(soundSettingsObject)},
        {QStringLiteral("trayRef"), QVariant::fromValue(trayObject)},
        {QStringLiteral("masterModelRef"), QVariant::fromValue(masterModelObject)},
        {QStringLiteral("timerRef"), QVariant::fromValue(timerObject)},
        {QStringLiteral("queueRef"), QVariant::fromValue(queueObject)},
        {QStringLiteral("clockRef"), QVariant::fromValue(clockObject)},
        {QStringLiteral("macOSControllerRef"), QVariant::fromValue(macOSControllerObject)},
    };

    QObject *object = component.createWithInitialProperties(initialProperties, engine.rootContext());
    if (!object) {
        QStringList errors;
        const auto errorList = component.errors();
        for (const QQmlError &error : errorList)
            errors << error.toString();
        qFatal("%s", qPrintable(errors.join('\n')));
    }

    return std::unique_ptr<QObject>(object);
}

std::unique_ptr<QObject> createNotificationSystem(NotificationFixture &fixture)
{
    return createNotificationSystem(fixture.engine, &fixture.settings, &fixture.soundSettings,
                                    &fixture.tray, &fixture.masterModel, &fixture.timer,
                                    &fixture.queue, &fixture.clock, &fixture.macOSController);
}

std::unique_ptr<QObject> createNotificationSystem(IntegratedNotificationTimerFixture &fixture)
{
    return createNotificationSystem(fixture.engine, &fixture.settings, &fixture.soundSettings,
                                    &fixture.tray, &fixture.masterModel, fixture.timer.get(),
                                    &fixture.queue, &fixture.clock, &fixture.macOSController);
}

} // namespace

#ifdef __APPLE__
std::unique_ptr<QObject> createMacOsReviewMacOSTests();
#endif

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

    void triggeredOnStartConsumesImmediateFirstSecond()
    {
        TimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.timer->setProperty("remainingTime", 10.0);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));

        const double remainingTime = fixture.timer->property("remainingTime").toDouble();
        QVERIFY2(remainingTime < 10.0, "start() should consume the initial triggeredOnStart tick");
        QVERIFY(remainingTime <= 9.0);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "stop"));
    }

    void clockGetTimeAfterUsesSingleSnapshotAcrossRollover()
    {
        QQmlEngine engine;
        auto clock = createInlineClock(engine, QStringLiteral(R"(
import QtQuick
import "."

Clock {
    property int callCount: 0

    function getTime() {
        callCount += 1
        if (callCount === 1)
            return { "h": 12, "min": 59, "sec": 59, "clock": "12:59" }
        return { "h": 13, "min": 0, "sec": 0, "clock": "13:00" }
    }
}
)"));

        QVariant returned;
        QVERIFY(QMetaObject::invokeMethod(clock.get(),
                                          "getTimeAfter",
                                          Q_RETURN_ARG(QVariant, returned),
                                          Q_ARG(QVariant, QVariant(60.0))));
        const QVariantMap time = returned.toMap();
        QCOMPARE(time.value(QStringLiteral("clock")).toString(), QStringLiteral("13:00"));
        QCOMPARE(time.value(QStringLiteral("h")).toInt(), 13);
        QCOMPARE(time.value(QStringLiteral("min")).toInt(), 0);
        QCOMPARE(time.value(QStringLiteral("sec")).toInt(), 59);
    }

    void clockGetNotificationTimeUsesSingleSnapshotAcrossRollover()
    {
        QQmlEngine engine;
        auto clock = createInlineClock(engine, QStringLiteral(R"(
import QtQuick
import "."

Clock {
    property int callCount: 0

    function getTime() {
        callCount += 1
        if (callCount === 1)
            return { "h": 12, "min": 59, "sec": 59, "clock": "12:59" }
        return { "h": 13, "min": 0, "sec": 0, "clock": "13:00" }
    }

    function getDuration() {
        return 60
    }
}
)"));

        QVariant returned;
        QVERIFY(QMetaObject::invokeMethod(clock.get(),
                                          "getNotificationTime",
                                          Q_RETURN_ARG(QVariant, returned)));
        const QVariantMap time = returned.toMap();
        QCOMPARE(time.value(QStringLiteral("clock")).toString(), QStringLiteral("13:00"));
        QCOMPARE(time.value(QStringLiteral("h")).toInt(), 13);
        QCOMPARE(time.value(QStringLiteral("min")).toInt(), 0);
        QCOMPARE(time.value(QStringLiteral("sec")).toInt(), 59);
    }

    void splitSegmentRolloverSchedulesNextSegment()
    {
        TimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
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

    void longSleepCatchUpUsesFullElapsedWallClockTime()
    {
        TimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.timer->setProperty("remainingTime", 36000.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        fixture.timer->setProperty("_lastTickMs",
                                   QDateTime::currentMSecsSinceEpoch() - 25200.0 * 1000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 1)));

        const double remainingTime = fixture.timer->property("remainingTime").toDouble();
        QVERIFY(qAbs(remainingTime - 10800.0) < 2.0);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "stop"));
    }

    void macOsCatchUpCompletionDoesNotRepeatScheduledNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 120.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 2000.0);
        fixture.timer->setProperty("_lastTickMs",
                                   QDateTime::currentMSecsSinceEpoch() - 121000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 121)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QVERIFY(fixture.macOSController.clearScheduledCalls >= 1);
    }

    void macOsOnTimeCompletionDoesNotDuplicateScheduledNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 120.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 100.0);
        fixture.timer->setProperty("_lastTickMs",
                                   QDateTime::currentMSecsSinceEpoch() - 120000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 120)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QVERIFY(fixture.macOSController.clearScheduledCalls >= 1);
    }

    void macOsOrdinaryOnTimeCompletionDoesNotDuplicateScheduledNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 1.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 100.0);
        fixture.timer->setProperty("_lastTickMs", QDateTime::currentMSecsSinceEpoch() - 1000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 1)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QVERIFY(fixture.macOSController.clearScheduledCalls >= 1);
    }

    void macOsCatchUpCompletionFallsBackWhenSchedulingFails()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.macOSController.scheduleNotificationResult = false;
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 120.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        QVariant suppressed = true;
        const double futureNowMs = QDateTime::currentMSecsSinceEpoch() + 122000.0;
        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(),
                                          "shouldSuppressCatchUpCompletion",
                                          Q_RETURN_ARG(QVariant, suppressed),
                                          Q_ARG(QVariant, QVariant(futureNowMs)),
                                          Q_ARG(QVariant, QVariant(true))));
        QVERIFY(!suppressed.toBool());
    }

    void macOsCatchUpCompletionWaitsForAsyncScheduleConfirmation()
    {
        NotificationFixture fixture;
        fixture.timer.running = true;
        fixture.timer.remainingTime = 120.0;
        fixture.timer.segmentTotalDuration = 120.0;
        fixture.timer.durationBound = 120.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        QVariant suppressed = true;
        const double futureNowMs = QDateTime::currentMSecsSinceEpoch() + 122000.0;
        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(),
                                          "shouldSuppressCatchUpCompletion",
                                          Q_RETURN_ARG(QVariant, suppressed),
                                          Q_ARG(QVariant, QVariant(futureNowMs)),
                                          Q_ARG(QVariant, QVariant(true))));
        QVERIFY(!suppressed.toBool());

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();

        suppressed = false;
        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(),
                                          "shouldSuppressCatchUpCompletion",
                                          Q_RETURN_ARG(QVariant, suppressed),
                                          Q_ARG(QVariant, QVariant(futureNowMs)),
                                          Q_ARG(QVariant, QVariant(true))));
        QVERIFY(suppressed.toBool());
    }

    void macOsCatchUpCompletionFallsBackWhenAsyncSchedulingFails()
    {
        NotificationFixture fixture;
        fixture.timer.running = true;
        fixture.timer.remainingTime = 120.0;
        fixture.timer.segmentTotalDuration = 120.0;
        fixture.timer.durationBound = 120.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, false);
        QCoreApplication::processEvents();

        QVariant suppressed = true;
        const double futureNowMs = QDateTime::currentMSecsSinceEpoch() + 122000.0;
        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(),
                                          "shouldSuppressCatchUpCompletion",
                                          Q_RETURN_ARG(QVariant, suppressed),
                                          Q_ARG(QVariant, QVariant(futureNowMs)),
                                          Q_ARG(QVariant, QVariant(true))));
        QVERIFY(!suppressed.toBool());
    }

    void macOsTriggeredOnStartSchedulesCompletionAfterInitialTick()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.queue.setItems({
            Segment{0, 10.0, 10.0, 10},
        });
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 10.0);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 9.0);
    }

    void macOsCatchUpSegmentBoundaryDoesNotRepeatScheduledNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 60.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 60.0, 60.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });

        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 90.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 2000.0);
        fixture.timer->setProperty("_lastTickMs", QDateTime::currentMSecsSinceEpoch() - 65000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 65)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 25.0);
    }

    void macOsOnTimeSegmentBoundaryDoesNotDuplicateScheduledNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 60.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 60.0, 60.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });

        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 90.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 100.0);
        fixture.timer->setProperty("_lastTickMs", QDateTime::currentMSecsSinceEpoch() - 60000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 60)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 30.0);
    }

    void macOsOrdinaryOnTimeSegmentBoundaryKeepsPopupWithoutDuplicateNotification()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
        fixture.settings.setShowOnSegmentStart(true);
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 1.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 1.0, 1.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });

        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 31.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));

        fixture.macOSController.resolveNotification(fixture.macOSController.lastRequestId, true);
        QCoreApplication::processEvents();
        fixture.notificationSystem->setProperty("scheduledNotificationAtMs",
                                                QDateTime::currentMSecsSinceEpoch() - 100.0);
        fixture.timer->setProperty("_lastTickMs", QDateTime::currentMSecsSinceEpoch() - 1000.0);
        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "triggered", Q_ARG(int, 1)));

        QCOMPARE(fixture.tray.sendCalls, 0);
        QCOMPARE(fixture.tray.popUpCalls, 1);
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
    }

    void macOsTriggeredOnStartSchedulesSplitBoundaryAfterInitialTick()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 60.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 60.0, 60.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 90.0);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 59.0);
    }

    void enablingSplitModeWhileRunningReschedulesMacBoundary()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 60.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 60.0, 60.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 90.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 90.0);

        fixture.preferences.setSplitToSequence(true);
        QCoreApplication::processEvents();

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 60.0);
        QCOMPARE(fixture.timer->property("segmentRemainingTime").toDouble(), 60.0);
        QCOMPARE(fixture.timer->property("segmentTotalDuration").toDouble(), 60.0);
    }

    void disablingSplitModeWhileRunningReschedulesMacBoundary()
    {
        IntegratedNotificationTimerFixture fixture;
        fixture.preferences.setSplitToSequence(true);
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 60.0),
            masterItem(1, QStringLiteral("Break"), 30.0),
        });
        fixture.queue.setItems({
            Segment{0, 60.0, 60.0, 10},
            Segment{1, 30.0, 30.0, 11},
        });
        fixture.timer = createTimer(fixture);
        fixture.notificationSystem = createNotificationSystem(fixture);
        fixture.timer->setProperty("notificationsRef",
                                   QVariant::fromValue(fixture.notificationSystem.get()));
        fixture.timer->setProperty("remainingTime", 90.0);
        fixture.timer->setProperty("triggeredOnStart", false);

        QVERIFY(QMetaObject::invokeMethod(fixture.timer.get(), "start"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 60.0);

        fixture.preferences.setSplitToSequence(false);
        QCoreApplication::processEvents();

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 90.0);
        QCOMPARE(fixture.timer->property("segmentTotalDuration").toDouble(), 90.0);
        QCOMPARE(fixture.timer->property("_activeSegmentKey").toInt(), -1);
    }

    void cmakeDoesNotRequireQtTestOutsideBuildTesting()
    {
        QFile cmakeFile(QStringLiteral(PILORAMA_SOURCE_DIR "/CMakeLists.txt"));
        QVERIFY(cmakeFile.open(QIODevice::ReadOnly | QIODevice::Text));
        const QString cmakeContents = QString::fromUtf8(cmakeFile.readAll());

        const QRegularExpression findPackageRe(
            QStringLiteral(R"(find_package\(Qt6 REQUIRED COMPONENTS([\s\S]*?)\))"));
        const QRegularExpressionMatch findPackageMatch = findPackageRe.match(cmakeContents);

        QVERIFY(findPackageMatch.hasMatch());
        QVERIFY2(!QRegularExpression(QStringLiteral(R"(\bTest\b)"))
                      .match(findPackageMatch.captured(1))
                      .hasMatch(),
                 "Qt6 Test should only be required when BUILD_TESTING is enabled");
    }

    void windowsInstallerVersionMatchesProjectVersion()
    {
        QFile cmakeFile(QStringLiteral(PILORAMA_SOURCE_DIR "/CMakeLists.txt"));
        QVERIFY(cmakeFile.open(QIODevice::ReadOnly | QIODevice::Text));
        const QString cmakeContents = QString::fromUtf8(cmakeFile.readAll());

        QFile installerFile(installerPath());
        QVERIFY(installerFile.open(QIODevice::ReadOnly | QIODevice::Text));
        const QString installerContents = QString::fromUtf8(installerFile.readAll());

        const QRegularExpression projectVersionRe(
            QStringLiteral(R"(project\s*\(\s*Pilorama\s+VERSION\s+([0-9.]+))"));
        const QRegularExpression installerVersionRe(
            QStringLiteral("#define\\s+MyAppVersion\\s+\"([0-9.]+)\""));

        const QRegularExpressionMatch projectMatch = projectVersionRe.match(cmakeContents);
        const QRegularExpressionMatch installerMatch = installerVersionRe.match(installerContents);

        QVERIFY(projectMatch.hasMatch());
        QVERIFY(installerMatch.hasMatch());
        QCOMPARE(installerMatch.captured(1), projectMatch.captured(1));
    }

    void scheduledNotificationUsesNextSegmentDetails()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
            masterItem(1, QStringLiteral("Break"), 120.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
            Segment{1, 120.0, 120.0, 11},
        });
        fixture.timer.running = true;
        fixture.timer.splitMode = true;
        fixture.timer.remainingTime = 420.0;
        fixture.timer.durationBound = 420.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));
        QCOMPARE(fixture.macOSController.scheduledMessage,
                 QStringLiteral("Duration: 2 min.  Ends at t+420"));
        QCOMPARE(fixture.macOSController.scheduledIconPath, QStringLiteral("icon://notification"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 300.0);
        QCOMPARE(fixture.clock.lastTimeAfterSecs, 420.0);
    }

    void infiniteModeFinalSegmentSchedulesNextCycleStart()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
            masterItem(1, QStringLiteral("Break"), 120.0),
        });
        fixture.queue.infiniteMode = true;
        fixture.queue.setItems({
            Segment{1, 120.0, 120.0, 17},
        });
        fixture.timer.running = true;
        fixture.timer.splitMode = true;
        fixture.timer.remainingTime = 120.0;
        fixture.timer.segmentTotalDuration = 120.0;
        fixture.timer.durationBound = 420.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Focus started"));
        QCOMPARE(fixture.macOSController.scheduledMessage,
                 QStringLiteral("Duration: 5 min.  Ends at t+420"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 120.0);
        QCOMPARE(fixture.clock.lastTimeAfterSecs, 420.0);
    }

    void scheduledNotificationUsesQueuedDurationForTrimmedSegment()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 1500.0),
            masterItem(1, QStringLiteral("Break"), 600.0),
        });
        fixture.queue.setItems({
            Segment{0, 1500.0, 1500.0, 10},
            Segment{1, 300.0, 300.0, 11},
        });
        fixture.timer.running = true;
        fixture.timer.splitMode = true;
        fixture.timer.remainingTime = 1800.0;
        fixture.timer.durationBound = 1800.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Break started"));
        QCOMPARE(fixture.macOSController.scheduledMessage,
                 QStringLiteral("Duration: 5 min.  Ends at t+1800"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 1500.0);
        QCOMPARE(fixture.clock.lastTimeAfterSecs, 1800.0);
    }

    void scheduledNotificationUsesCompletionDetailsForFinalSegment()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
        });
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 300.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledMessage, QStringLiteral("Duration: 5 min"));
        QCOMPARE(fixture.macOSController.scheduledIconPath, QStringLiteral("icon://notification"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 300.0);
        QCOMPARE(fixture.clock.lastTimeAfterSecs, -1.0);
    }

    void finiteNonSplitMultiSegmentSchedulesOverallCompletion()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
            masterItem(1, QStringLiteral("Break"), 120.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
            Segment{1, 120.0, 120.0, 11},
        });
        fixture.timer.running = true;
        fixture.timer.splitMode = false;
        fixture.timer.remainingTime = 420.0;
        fixture.timer.segmentTotalDuration = 420.0;
        fixture.timer.durationBound = 420.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledMessage, QStringLiteral("Duration: 7 min"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 420.0);
        QCOMPARE(fixture.clock.lastTimeAfterSecs, -1.0);
    }

    void scheduledCompletionUsesCurrentSegmentDurationForSplitFinalSegment()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 1500.0),
            masterItem(1, QStringLiteral("Break"), 300.0),
        });
        fixture.queue.setItems({
            Segment{1, 300.0, 300.0, 11},
        });
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 1800.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QCOMPARE(fixture.macOSController.scheduledTitle, QStringLiteral("Time ran out"));
        QCOMPARE(fixture.macOSController.scheduledMessage, QStringLiteral("Duration: 5 min"));
        QCOMPARE(fixture.macOSController.scheduledSeconds, 300.0);
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
                    QByteArrayLiteral("bool"),
                }) {
                found = true;
                break;
            }
        }

        QVERIFY(found);
    }

    void scheduleNextSegmentForwardsEnabledSoundPreference()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
        });
        fixture.settings.setSoundMuted(false);
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 300.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QVERIFY(fixture.macOSController.scheduledPlaySound);
    }

    void mutingSoundWhileRunningReschedulesMacBoundary()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
        });
        fixture.settings.setSoundMuted(false);
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 300.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QVERIFY(fixture.macOSController.scheduledPlaySound);

        fixture.settings.setSoundMuted(true);
        QCoreApplication::processEvents();

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QVERIFY(!fixture.macOSController.scheduledPlaySound);
    }

    void unmutingSoundWhileRunningReschedulesMacBoundary()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
        });
        fixture.settings.setSoundMuted(true);
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 300.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));
        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QVERIFY(!fixture.macOSController.scheduledPlaySound);

        fixture.settings.setSoundMuted(false);
        QCoreApplication::processEvents();

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 2);
        QVERIFY(fixture.macOSController.scheduledPlaySound);
    }

    void scheduleNextSegmentRespectsMutedSoundPreference()
    {
        NotificationFixture fixture;
        fixture.masterModel.setItems({
            masterItem(0, QStringLiteral("Focus"), 300.0),
        });
        fixture.queue.setItems({
            Segment{0, 300.0, 300.0, 10},
        });
        fixture.settings.setSoundMuted(true);
        fixture.timer.running = true;
        fixture.timer.remainingTime = 300.0;
        fixture.timer.segmentTotalDuration = 300.0;
        fixture.timer.durationBound = 300.0;
        fixture.notificationSystem = createNotificationSystem(fixture);

        QVERIFY(QMetaObject::invokeMethod(fixture.notificationSystem.get(), "scheduleNextSegment"));

        QCOMPARE(fixture.macOSController.scheduleNotificationCalls, 1);
        QVERIFY(!fixture.macOSController.scheduledPlaySound);
    }
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    int status = 0;
    PiloramaReviewTests tests;
    status |= QTest::qExec(&tests, argc, argv);
#ifdef __APPLE__
    std::unique_ptr<QObject> macOsTests = createMacOsReviewMacOSTests();
    status |= QTest::qExec(macOsTests.get(), argc, argv);
#endif
    return status;
}

#include "pilorama_review_tests.moc"
