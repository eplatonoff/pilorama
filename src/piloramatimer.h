#ifndef PILORAMATIMER_H
#define PILORAMATIMER_H

#include <QTimer>

class PiloramaTimer : public QTimer
{
    Q_OBJECT
public:
    Q_PROPERTY(bool running MEMBER _running NOTIFY runningChanged)
    Q_PROPERTY(bool triggeredOnStart MEMBER _triggeredOnStart NOTIFY triggeredOnStartChanged)

    PiloramaTimer(QObject *parent = nullptr);

public slots:
    void start();
    void stop();

signals:
    void runningChanged(bool);
    void triggered(int elapsedSecs);
    void triggeredOnStartChanged();


private:
    void checkElapsedTime();

    qint64 _elapsedSecsSinceEpoch = 0;
    bool _running = false;

    bool _triggeredOnStart = false;
};

#endif // PILORAMATIMER_H
