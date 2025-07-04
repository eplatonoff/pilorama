#include "piloramatimer.h"
#include "trayimageprovider.h"
#include "notificationdotprovider.h"
#include "mac/MacOSController.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>
#include <QSystemTrayIcon>
#include <QPixmap>
#include <QApplication>
#include <QQmlContext>


int main(int argc, char *argv[])
{
    MacOSController macOSController;

    QApplication app(argc, argv);

    app.setOrganizationName("Some Humans");
    app.setOrganizationDomain("somehumans.com");
    app.setApplicationName("Pilorama");

    app.setApplicationVersion(APP_VERSION);

    QQmlApplicationEngine engine;
    engine.addImageProvider("tray_icon_provider", new TrayImageProvider());
    engine.addImageProvider("notification_dot_provider", new NotificationDotProvider());
    macOSController.setEngine(&engine);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

    }, Qt::QueuedConnection);

    qmlRegisterType<PiloramaTimer>("Pilorama", 1, 0, "Timer");

    engine.rootContext()->setContextProperty("MacOSController", &macOSController);

	qputenv("QML_XHR_ALLOW_FILE_WRITE", QByteArray("1"));
	qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

    engine.load(url);

    return app.exec();
}
