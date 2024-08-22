cmake_minimum_required(VERSION 3.16)
project(Pilorama VERSION 3.0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
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

include_directories(".")

file(GLOB SRCS_TOP ${PROJECT_SOURCE_DIR}/*.cpp)
file( GLOB_RECURSE SRCS_NESTED)
file( GLOB_RECURSE HDRS)
file( GLOB_RECURSE QRCS *.qrc)

IF(APPLE)
    SET(CMAKE_EXE_LINKER_FLAGS "-framework Foundation -w")
    SET(PLATFORM_FILES
            mac/utility.mm
    )
ENDIF()

set(SOURCE_FILES ${SRCS_TOP} ${SRCS_NESTED} ${HDRS} ${QRCS})

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
    set_target_properties(${PROJECT_NAME} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_BUNDLE_IDENTIFIER "com.sigonna.opensource"
    )
endif()

# if(WIN32)
#     set(RC_FILE ${CMAKE_SOURCE_DIR}/assets/app_icons/icon.ico)
#     set_source_files_properties(${RC_FILE} PROPERTIES LANGUAGE RC)
#     target_sources(${PROJECT_NAME} PRIVATE ${RC_FILE})
# endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE QT_DEPRECATED_WARNINGS)

target_link_libraries(${PROJECT_NAME} PUBLIC
        Qt::Quick
        Qt::Widgets
        Qt::Svg
        Qt::Xml
        PRIVATE Qt6::Core
        PRIVATE Qt6::Multimedia
)
