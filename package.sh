#!/bin/bash

xcodebuild \
    -project "ember-macos.xcodeproj" \
    -scheme "ember-macos" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    -archivePath "build/ember-macos.xcarchive"

plutil -convert xml1 - -o "exportOptions.plist" << EOF
    {
        "destination": "export",
        "method": "mac-application"
    }
EOF

xcodebuild \
    -exportArchive \
    -archivePath "build/ember-macos.xcarchive" \
    -exportPath "build" \
    -exportOptionsPlist "exportOptions.plist"


create-dmg --dmg-title='Ember-MacOS' 'build/ember-macos.app' ./