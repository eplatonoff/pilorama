#include "piloramatimer.h"

PiloramaTimer::PiloramaTimer(QObject *parent) : QTimer(parent)
{           
    setTimerType(Qt::PreciseTimer);
}

void PiloramaTimer::start()
{
    QTimer::start();
    _running = true;
    emit runningChanged();
}

void PiloramaTimer::stop()
{
    QTimer::stop();
    _running = false;
    emit runningChanged();
}
