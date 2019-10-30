#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>



void disable_app_nap();


int main(int argc, char *argv[])
{
    #ifdef __APPLE__
       #if TARGET_OS_MAC
        disable_app_nap();
       #endif /* TARGET_OS_MAC */
    #endif /* __APPLE__ */


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {

        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
