QT += quick widgets svg xml

CONFIG += c++17


OBJECTIVE_SOURCES += mac/utility.mm

QMAKE_INFO_PLIST = mac/Info.plist

macx: {
    LIBS += -framework Foundation
    ICON = assets/app_icons/icon.icns
}

win*: {
    RC_ICONS = assets/app_icons/icon.ico
}



# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        piloramatimer.cpp \
        trayimageprovider.cpp

HEADERS += \
    piloramatimer.h \
    trayimageprovider.h


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
unix:
    macx: target.path = /usr/local/bin
    !android: target.path = /usr/bin
!isEmpty(target.path): INSTALLS += target

TARGET=Pilorama
QMAKE_TARGET_BUNDLE_PREFIX=com.sigonna.opensource

VERSION=3.0.2
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
