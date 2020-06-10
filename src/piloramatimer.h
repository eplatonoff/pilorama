#ifndef PILORAMATIMER_H
#define PILORAMATIMER_H

#include <QTimer>
#include <QQmlEngine>


class PiloramaTimer : public QTimer
{
    Q_OBJECT
public:
    Q_PROPERTY(bool running MEMBER _running NOTIFY runningChanged)

    PiloramaTimer(QObject *parent = nullptr);

public slots:
    void start();
    void stop();

signals:
    void runningChanged();


private:
    bool _running = false;
};

#endif // PILORAMATIMER_H
