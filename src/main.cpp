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

        qDebug() << "obj created";

//        QTimer::singleShot(5 * 1000, [obj]() {
//            QMetaObject::invokeMethod(obj, "timerTest");
//        });

//        QTimer::singleShot(5 * 1000 * 60, [obj]() {
//            qDebug() << "timer test in c++";
//            QMetaObject::invokeMethod(obj, "timerTest");
//        });


//        auto timer = new QTimer();
//        timer->setTimerType(Qt::PreciseTimer);
//        QTimer::connect(timer, &QTimer::timeout, [obj]() {
//            QMetaObject::invokeMethod(obj, "timerTest", Qt::QueuedConnection);
//        });
//        timer->start(1000);


    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
