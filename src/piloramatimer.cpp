#include "piloramatimer.h"

#include <QDebug>
#include <QDateTime>

PiloramaTimer::PiloramaTimer(QObject *parent) : QTimer(parent)
{           
    setTimerType(Qt::PreciseTimer);

    connect(this, &QTimer::timeout, this, &PiloramaTimer::checkElapsedTime);
}

void PiloramaTimer::start()
{
    _elapsedSecsSinceEpoch = QDateTime::currentSecsSinceEpoch();

    QTimer::start();

    _running = true;
    emit runningChanged();

    if (_triggeredOnStart) {
        emit triggered(interval() / 1000);
    }
}

void PiloramaTimer::stop()
{
    QTimer::stop();

    _running = false;
    emit runningChanged();
}

void PiloramaTimer::checkElapsedTime()
{
    const auto currentSecs = QDateTime::currentSecsSinceEpoch();
    const auto elapsedSecsSinceTimeout =  currentSecs - _elapsedSecsSinceEpoch;
    _elapsedSecsSinceEpoch = currentSecs;

    if (elapsedSecsSinceTimeout > 0) {
        emit triggered(elapsedSecsSinceTimeout);
    } else {
        qWarning() << "PiloramaTimer – timeout in less than a second";
    }
}
