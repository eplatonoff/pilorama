#include "piloramatimer.h"
#include "trayimageprovider.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>
#include <QSystemTrayIcon>
#include <QPixmap>
#include <QApplication>
#include <QQmlContext>

void mac_disable_app_nap();
void mac_show_in_dock();

int main(int argc, char *argv[])
{
    #ifdef __APPLE__
       #if TARGET_OS_MAC
        mac_disable_app_nap();
       #endif /* TARGET_OS_MAC */
    #endif /* __APPLE__ */

    QApplication app(argc, argv);

    app.setOrganizationName("Some Humans");
    app.setOrganizationDomain("somehumans.com");
    app.setApplicationName("Pilorama");

    app.setApplicationVersion(APP_VERSION);

    QQmlApplicationEngine engine;
    engine.addImageProvider("tray_icon_provider", new TrayImageProvider());

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {

        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

    }, Qt::QueuedConnection);

    qmlRegisterType<PiloramaTimer>("Pilorama", 1, 0, "Timer");

    engine.load(url);

    #ifdef __APPLE__
        #if TARGET_OS_MAC
            mac_show_in_dock();
        #endif /* TARGET_OS_MAC */
    #endif /* __APPLE__ */

    return app.exec();
}
