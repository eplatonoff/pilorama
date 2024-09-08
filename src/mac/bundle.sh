#!/bin/bash

# This script is intended to be run as a "Run Script" build phase in Xcode.

APP_BUNDLE_PATH="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app"
QT_BIN_DIR="${HOME}/bin/Qt/6.7.2/macos/bin"  # Adjust this if your Qt installation is in a different location


if [ "${CONFIGURATION}" == "Release" ] || [ "${CONFIGURATION}" == "MinSizeRel" ]; then

    # Run macdeployqt using absolute paths derived from Xcode environment variables
    "${QT_BIN_DIR}/macdeployqt" "$APP_BUNDLE_PATH" -appstore-compliant -qmldir="${SRCROOT}"

    # Find and remove all .dSYM directories inside the PlugIns directory before signing
    find "$APP_BUNDLE_PATH/" -type d -name "*.dSYM" | while read dsym; do
        echo "Removing .dSYM from the bundle: $dsym"
        rm -rf "$dsym"
    done

fi
