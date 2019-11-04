//
// Created by Евгений Платонов on 11/4/19.
//

#ifndef QML_TIMER_NOTIFICATIONSYSTEM_H
#define QML_TIMER_NOTIFICATIONSYSTEM_H

#include <QObject>
#include <QPointer>

class QSystemTrayIcon;



class NotificationSystem: public QObject {
    Q_OBJECT
public:
	explicit NotificationSystem(QObject *parent = nullptr);
    ~NotificationSystem() override;

	enum Type {
		POMODORO,
		PAUSE,
		BREAK,
	};

	Q_ENUM(Type)

public slots:
	void sendNotification(Type type);


private:
	void _createTrayIcon();

	QPointer<QSystemTrayIcon> trayIcon;
};


#endif //QML_TIMER_NOTIFICATIONSYSTEM_H
