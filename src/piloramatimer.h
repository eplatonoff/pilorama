#ifndef PILORAMATIMER_H
#define PILORAMATIMER_H

#include <QTimer>
#include <QQmlEngine>


class PiloramaTimer : public QTimer
{
    Q_OBJECT
public:
    Q_PROPERTY(float duration MEMBER _duration NOTIFY durationChanged)
    Q_PROPERTY(float durationBound MEMBER _durationBound NOTIFY durationBoundChanged)
    Q_PROPERTY(float splitDuration MEMBER _splitDuration NOTIFY splitDurationChanged)
    Q_PROPERTY(float timerLimit MEMBER _timerLimit NOTIFY timerLimitChanged)
    Q_PROPERTY(bool running MEMBER _running NOTIFY runningChanged)

    PiloramaTimer(QObject *parent = nullptr);

public slots:
    void start();
    void stop();

signals:
    void durationChanged();
    void durationBoundChanged();
    void splitDurationChanged();
    void timerLimitChanged();
    void runningChanged();


private:
    float _duration;
    float _durationBound;
    float _splitDuration;
    float _timerLimit;
    bool _running = false;
};

#endif // PILORAMATIMER_H
