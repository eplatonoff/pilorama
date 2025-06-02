cmake_minimum_required(VERSION 3.16)
project(Pilorama VERSION 4.0.6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 REQUIRED COMPONENTS
        Core
        Quick
        Widgets
        Svg
        Xml
        Multimedia
)

include_directories(${PROJECT_SOURCE_DIR})
file(GLOB_RECURSE SRCS RELATIVE ${PROJECT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/*.cpp)
file(GLOB_RECURSE HDRS RELATIVE ${PROJECT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/*.h)
file(GLOB_RECURSE QRCS RELATIVE ${PROJECT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/*.qrc)

list(FILTER SRCS EXCLUDE REGEX "^build/")
list(FILTER HDRS EXCLUDE REGEX "^build/")
list(FILTER QRCS EXCLUDE REGEX "^build/")

IF(APPLE)
    SET(CMAKE_EXE_LINKER_FLAGS "-framework Foundation -w")
    SET(PLATFORM_FILES
            mac/utility.mm
    )
ENDIF()

set(SOURCE_FILES ${SRCS} ${HDRS} ${QRCS})

qt_add_resources(SOURCE_FILES qml.qrc)

if (APPLE)
    set(MACOSX_BUNDLE_ICON_FILE icon.icns)

    set(app_icon_macos "${CMAKE_CURRENT_SOURCE_DIR}/assets/app_icons/icon.icns")
    set_source_files_properties(${app_icon_macos} PROPERTIES
           MACOSX_PACKAGE_LOCATION "Resources")

    list(APPEND PLATFORM_FILES ${app_icon_macos})
endif ()

if(WIN32)
    set(app_icon "${CMAKE_CURRENT_SOURCE_DIR}/assets/app_icons/icon.ico")
    set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/icon.rc")

    file(WRITE ${app_icon_resource_windows} "IDI_ICON1 ICON DISCARDABLE \"${app_icon}\"")

    list(APPEND PLATFORM_FILES ${app_icon_resource_windows})
endif()

qt_add_executable( ${PROJECT_NAME} ${SOURCE_FILES} ${PLATFORM_FILES})

target_compile_definitions(${PROJECT_NAME} PRIVATE APP_VERSION="${PROJECT_VERSION}")

if(APPLE)
    if(CMAKE_GENERATOR STREQUAL "Xcode")
        add_custom_command(
            TARGET ${PROJECT_NAME}
            POST_BUILD
            COMMAND /bin/sh ${CMAKE_CURRENT_SOURCE_DIR}/mac/bundle.sh
            COMMENT "Bundle Qt plugins and frameworks into the app bundle"
        )
    endif()

    set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0")

    set_target_properties(${PROJECT_NAME} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/mac/Info.plist"
            MACOSX_BUNDLE_GUI_IDENTIFIER "com.sigonna.opensource.Pilorama"
            MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"

            XCODE_ATTRIBUTE_INFOPLIST_KEY_LSApplicationCategoryType "public.app-category.utilities"
            XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/mac/Entitlements.plist"
            XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "UT7K2SYU3T"
            XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Manual"
            XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME "YES"
    )
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DEPRECATED_WARNINGS)

target_link_libraries(${PROJECT_NAME} PUBLIC
        Qt::Quick
        Qt::Widgets
        Qt::Svg
        Qt::Xml
        PRIVATE Qt6::Core
        PRIVATE Qt6::Multimedia
)
