#include "piloramatimer.h"
#include "trayimageprovider.h"
#include "mac/MacOSController.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcessEnvironment>
#include <QFile>
#include <QTimer>
#include <QSystemTrayIcon>
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

class FileSaver : public QObject {
    Q_OBJECT
public:
    explicit FileSaver(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE bool saveToFile(const QString &filePath, const QString &data) {
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            return false; // If opening the file failed, return false.
        }

        QTextStream out(&file);
        out << data; // Write data to the file.
        file.close();
        return true; // Return true if the file was saved successfully.
    }
};


int main(int argc, char *argv[])
{
    // Set environment variable to allow file reading with XMLHttpRequest
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

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


    FileSaver fileSaver;
    engine.rootContext()->setContextProperty("fileSaver", &fileSaver);


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
