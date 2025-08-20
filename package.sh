#!/bin/bash

xcodebuild \
    -project "EmberMate.xcodeproj" \
    -scheme "EmberMate" \
    -destination "generic/platform=macOS" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    -archivePath "build/EmberMate.xcarchive"

plutil -convert xml1 - -o "exportOptions.plist" << EOF
    {
        "destination": "export",
        "method": "mac-application"
    }
EOF

xcodebuild \
    -exportArchive \
    -archivePath "build/EmberMate.xcarchive" \
    -exportPath "build" \
    -exportOptionsPlist "exportOptions.plist"

# Remove existing DMG if it exists
rm -f "EmberMate 1.0.dmg"

create-dmg --dmg-title='EmberMate' 'build/EmberMate.app' ./