#include "piloramatimer.h"
#include "trayimageprovider.h"
#include "mac/MacOSController.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>
#include <QSystemTrayIcon>
#include <QPixmap>
#include <QApplication>
#include <QQmlContext>

class AppStateHandler : public QObject
{
    Q_OBJECT
public:
    AppStateHandler() {}

    signals:
        void applicationStateChanged(Qt::ApplicationState state);
};


int main(int argc, char *argv[])
{
    MacOSController macOSController;
    macOSController.disableAppNap();

    QApplication app(argc, argv);

    app.setOrganizationName("Some Humans");
    app.setOrganizationDomain("somehumans.com");
    app.setApplicationName("Pilorama");

    app.setApplicationVersion(APP_VERSION);

    QQmlApplicationEngine engine;
    engine.addImageProvider("tray_icon_provider", new TrayImageProvider());

    const QUrl url(QStringLiteral("qrc:/main.qml"));


    AppStateHandler appStateHandler;
    QObject::connect(&app, &QApplication::applicationStateChanged,
                     &appStateHandler, &AppStateHandler::applicationStateChanged);

    engine.rootContext()->setContextProperty("appStateHandler", &appStateHandler);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

    }, Qt::QueuedConnection);

    qmlRegisterType<PiloramaTimer>("Pilorama", 1, 0, "Timer");

    engine.rootContext()->setContextProperty("MacOSController", &macOSController);

    engine.load(url);

    return app.exec();
}

#include "main.moc"
