#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>
#include <QSystemTrayIcon>
#include <QPixmap>
#include <QApplication>



void disable_app_nap();


int main(int argc, char *argv[])
{
    #ifdef __APPLE__
       #if TARGET_OS_MAC
        disable_app_nap();
       #endif /* TARGET_OS_MAC */
    #endif /* __APPLE__ */


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {

        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

    }, Qt::QueuedConnection);

    QSystemTrayIcon trayIcon(&app);

    QTimer::singleShot(3000, [&trayIcon]() {

        auto pixmap = QPixmap(":/img/play.svg");

        QIcon icon(pixmap);

        trayIcon.setIcon(icon);
        trayIcon.show();

        trayIcon.showMessage("Test title", "Test message");
    });


    engine.load(url);

    return app.exec();
}
