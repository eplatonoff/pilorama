import QtQuick
import QtMultimedia

QtObject {
    id: notifications

    property var settings
    property var soundSettings
    property var trayRef
    property var masterModelRef
    property var timerRef
    property var queueRef
    property var clockRef
    property var macOSControllerRef
    readonly property bool soundMuted: settings ? settings.soundMuted : false
    property real scheduledNotificationAtMs: -1
    property string scheduledBoundaryKind: ""
    property int scheduledBoundaryKey: -1
    property int pendingBoundaryRequestId: -1
    property real pendingBoundaryAtMs: -1
    property string pendingBoundaryKind: ""
    property int pendingBoundaryKey: -1

    // Default and effective sound paths
    property url effectiveSoundPath: soundSettings.effectiveSoundPath
    property url currentSoundSource: effectiveSoundPath
    property bool pendingPlay: false

    onEffectiveSoundPathChanged: {
        currentSoundSource = effectiveSoundPath;
    }

    // QtObject has no default property; SoundEffect must be declared as a property.
    property SoundEffect soundNotification: SoundEffect {
        muted: notifications.soundMuted
        // Let Qt choose the default audio device to avoid null connections
        source: notifications.currentSoundSource
        onStatusChanged: {
            const status = notifications.soundNotification.status
            var currentSource = Qt.resolvedUrl(String(source));
            var defaultSource = Qt.resolvedUrl(String(notifications.soundSettings.defaultSound));
            if (status === SoundEffect.Error && currentSource !== defaultSource) {
                console.warn("SoundEffect: unsupported audio format:", source, "- will use fallback", notifications.soundSettings.defaultSound);
                notifications.currentSoundSource = notifications.soundSettings.defaultSound;
            } else if (status === SoundEffect.Ready && notifications.pendingPlay) {
                notifications.pendingPlay = false;
                notifications.soundNotification.play();
            }
        }
    }

    property Connections scheduleResolutionConnections: Connections {
        target: notifications.macOSControllerRef

        function onNotificationScheduleResolved(requestId, success) {
            if (success) {
                notifications.confirmScheduledBoundary(requestId)
            } else {
                notifications.clearPendingBoundary(requestId)
            }
        }
    }

    onSoundMutedChanged: {
        if (soundMuted)
            stopSound();
        if (Qt.platform.os === "osx"
                && timerRef
                && timerRef.running
                && (pendingBoundaryRequestId > 0 || scheduledNotificationAtMs >= 0)) {
            scheduleNextSegment()
        }
    }

    function toggleSoundNotifications() {
        if (settings) {
            settings.soundMuted = !settings.soundMuted;
        }
    }

    function stopSound() {
        pendingPlay = false;
        soundNotification.stop();
    }

    function playNotificationSound() {
        pendingPlay = true;
        if (soundNotification.status === SoundEffect.Ready) {
            pendingPlay = false;
            soundNotification.play();
        }
    }

    function sendWithSound(name) {
        playNotificationSound();
        trayRef.send(name)
    }

    function sendFromItem(item) {
        sendWithSound(masterModelRef.get(item.id).name)
        popUpForSegmentStart()
    }

    function popUpForSegmentStart() {
        if (settings.showOnSegmentStart)
            trayRef.popUp()
    }

    function clearScheduled() {
        scheduledNotificationAtMs = -1
        scheduledBoundaryKind = ""
        scheduledBoundaryKey = -1
        clearPendingBoundary()
        if (Qt.platform.os === "osx")
            macOSControllerRef.clearScheduledNotifications()
    }

    function queueItemDetails(item) {
        return item ? masterModelRef.get(item.id) : null
    }

    function queuedDuration(item) {
        if (!item)
            return 0
        if (item.total !== undefined)
            return item.total
        return item.duration
    }

    function timerSplitMode() {
        if (timerRef && timerRef.splitMode !== undefined)
            return timerRef.splitMode
        if (queueRef && queueRef.infiniteMode !== undefined)
            return queueRef.infiniteMode
        return false
    }

    function rememberScheduledBoundary(kind, seconds, key = -1) {
        scheduledBoundaryKind = kind
        scheduledBoundaryKey = key
        scheduledNotificationAtMs = Date.now() + seconds * 1000
    }

    function rememberPendingBoundary(requestId, kind, seconds, key = -1) {
        pendingBoundaryRequestId = requestId
        pendingBoundaryKind = kind
        pendingBoundaryKey = key
        pendingBoundaryAtMs = Date.now() + seconds * 1000
    }

    function clearPendingBoundary(requestId = -1) {
        if (requestId >= 0 && requestId !== pendingBoundaryRequestId)
            return
        pendingBoundaryRequestId = -1
        pendingBoundaryAtMs = -1
        pendingBoundaryKind = ""
        pendingBoundaryKey = -1
    }

    function confirmScheduledBoundary(requestId) {
        if (requestId !== pendingBoundaryRequestId)
            return
        scheduledBoundaryKind = pendingBoundaryKind
        scheduledBoundaryKey = pendingBoundaryKey
        scheduledNotificationAtMs = pendingBoundaryAtMs
        clearPendingBoundary()
    }

    function scheduleMacBoundary(kind, seconds, title, message, iconPath, key = -1) {
        const requestId = macOSControllerRef.scheduleNotification(title,
                                                                  message,
                                                                  iconPath,
                                                                  seconds,
                                                                  !soundMuted)
        if (requestId > 0)
            rememberPendingBoundary(requestId, kind, seconds, key)
    }

    function shouldSuppressCatchUpCompletion(nowMs, isCatchUp = true) {
        return shouldSuppressCatchUpBoundary("completion", -1, nowMs, isCatchUp)
    }

    function shouldSuppressCatchUpSegment(item, nowMs, isCatchUp = true) {
        return shouldSuppressCatchUpBoundary("segment",
                                            item && item.key !== undefined ? item.key : -1,
                                            nowMs,
                                            isCatchUp)
    }

    function shouldSuppressCatchUpBoundary(kind, key, nowMs, isCatchUp = true) {
        if (Qt.platform.os !== "osx")
            return false
        if (scheduledBoundaryKind !== kind)
            return false
        if (scheduledBoundaryKey !== key)
            return false
        if (scheduledNotificationAtMs < 0 || nowMs <= 0)
            return false
        return nowMs >= scheduledNotificationAtMs
    }

    function scheduledCompletionDuration(item) {
        if (item)
            return queuedDuration(item)
        if (timerRef && timerRef.segmentTotalDuration !== undefined
                && timerRef.segmentTotalDuration > 0) {
            return timerRef.segmentTotalDuration
        }
        if (timerRef && timerRef.durationBound !== undefined)
            return timerRef.durationBound
        if (timerRef && timerRef.remainingTime !== undefined)
            return timerRef.remainingTime
        return 0
    }

    function nextScheduledItem() {
        if (!timerSplitMode())
            return null
        if (queueRef.count > 1)
            return queueRef.get(1)
        if (!queueRef.infiniteMode)
            return null

        const nextCycleItem = masterModelRef.get(0)
        if (!nextCycleItem || nextCycleItem.id === undefined)
            return null

        // Infinite mode rebuilds a fresh batch once the queue drains, resetting keys.
        return {
            "id": nextCycleItem.id,
            "duration": nextCycleItem.duration,
            "total": nextCycleItem.duration,
            "key": 0
        }
    }

    function scheduleNextSegment() {
        clearScheduled()

        if (Qt.platform.os !== "osx")
            return

        if (!timerRef.running)
            return

        const first = queueRef.first()
        if (!first) {
            const remainingSecs = Math.max(0, timerRef.remainingTime)
            if (remainingSecs <= 0)
                return
            const completionDuration = scheduledCompletionDuration(null)
            scheduleMacBoundary("completion",
                                remainingSecs,
                                "Time ran out",
                                "Duration: " + completionDuration / 60 + " min",
                                trayRef.notificationIconURL())
            return
        }

        const secs = Math.max(0, first.duration)
        if (secs <= 0)
            return

        const next = nextScheduledItem()
        if (!next) {
            const completionSecs = timerSplitMode() ? secs : Math.max(0, timerRef.remainingTime)
            const completionDuration = scheduledCompletionDuration(timerSplitMode() ? first : null)
            scheduleMacBoundary("completion",
                                completionSecs,
                                "Time ran out",
                                "Duration: " + completionDuration / 60 + " min",
                                trayRef.notificationIconURL())
            return
        }

        const nextItem = queueItemDetails(next)
        const nextDuration = queuedDuration(next)
        const endTime = clockRef.getTimeAfter(secs + nextDuration).clock
        const message = "Duration: " + nextDuration / 60 + " min.  Ends at " + endTime
        scheduleMacBoundary("segment",
                            secs,
                            nextItem.name + " started",
                            message,
                            trayRef.notificationIconURL(next),
                            next.key !== undefined ? next.key : -1)
    }
}
