cmake_minimum_required(VERSION 3.15.3)
project(qml-timer)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package( Qt5Core REQUIRED)
find_package( Qt5Quick REQUIRED)

include_directories(
		"."
)

file(GLOB SRCS_TOP ${PROJECT_SOURCE_DIR}/*.cpp)
file( GLOB_RECURSE QRCS *.qrc)

set(SOURCE_FILES ${SRCS_TOP} ${QRCS})

add_executable( ${PROJECT_NAME} ${SOURCE_FILES} )
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

target_link_libraries(${PROJECT_NAME}  Qt5::Core Qt5::Quick )