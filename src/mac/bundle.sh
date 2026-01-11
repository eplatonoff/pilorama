#!/bin/bash

# This script is intended to be run as a "Run Script" build phase in Xcode.

APP_BUNDLE_PATH="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app"
QT_BIN_DIR="${HOME}/bin/Qt/6.10.1/macos/bin"  # Adjust this if your Qt installation is in a different location


#if [ "${CONFIGURATION}" == "Release" ] || [ "${CONFIGURATION}" == "MinSizeRel" ] || [ "${CONFIGURATION}" == "Debug" ]; then
    "${QT_BIN_DIR}/macdeployqt" "$APP_BUNDLE_PATH" -qmldir="${SRCROOT}" -appstore-compliant  -codesign="$EXPANDED_CODE_SIGN_IDENTITY" -hardened-runtime

    find "$APP_BUNDLE_PATH/" -type d -name "*.dSYM" | while read dsym; do
        echo "Removing .dSYM from the bundle: $dsym"
        rm -rf "$dsym"
    done
#fi
