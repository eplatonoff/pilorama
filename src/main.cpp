#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    {

        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        qDebug() << "obj created";

        QTimer::singleShot(5 * 1000, [obj]() {
            QMetaObject::invokeMethod(obj, "timerTest");
        });

        QTimer::singleShot(5 * 1000 * 60, [obj]() {
            QMetaObject::invokeMethod(obj, "timerTest");
        });


    }, Qt::QueuedConnection);



    engine.load(url);

    return app.exec();
}
