//
// Created by Евгений Платонов on 11/4/19.
//

#include "notificationsystem.h"

#include <QSystemTrayIcon>
#include <QDebug>


NotificationSystem::NotificationSystem(QObject *parent) : QObject(parent) {
	if (QSystemTrayIcon::isSystemTrayAvailable())
		if (QSystemTrayIcon::supportsMessages())
			_createTrayIcon();
}

void NotificationSystem::_createTrayIcon() {
    trayIcon = new QSystemTrayIcon(this);
    trayIcon->setIcon(QIcon(":assets/app_icons/trayicon.icns"));
    trayIcon->show();
}

void NotificationSystem::send(Type type) {
	if (trayIcon) {
		switch (type) {
			case Type::POMODORO:
				trayIcon->showMessage("Pomodoro timer", "Pomodoro started");
				break;
			case Type::PAUSE:
				trayIcon->showMessage("Pomodoro timer", "Pause started");
				break;
			case Type::BREAK:
				trayIcon->showMessage("Pomodoro timer", "Break started");
				break;
            case Type::STOP:
                trayIcon->showMessage("Pomodoro timer", "Time ran out");
                break;
		}
	}

}

NotificationSystem::~NotificationSystem() {

}
