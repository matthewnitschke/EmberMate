#!/usr/bin/env zx

/**
 * package.mjs runs the necessary steps to generate a packaged app for EmberMate
 * 
 * Dependencies:
 * - zx: https://google.github.io/zx/
 * - create-dmg: https://github.com/create-dmg/create-dmg
 * 
 * Execution: `$ ./package.mjs`
 */

const currentVersion = (await $`agvtool what-version -terse`).text().trim()

const shouldUpdate = (await question(`Current project version is ${currentVersion}. Would you like to update this? (Y/n): `)).trim().toLowerCase()
if (shouldUpdate == '' || shouldUpdate == 'y') {
  const newVersion = (await question(`Enter new version: `)).trim()
  await $`agvtool new-version ${newVersion}`
  await $`agvtool new-marketing-version ${newVersion}`
}

await spinner('Building Project', () => $`
xcodebuild \
    -project "EmberMate.xcodeproj" \
    -scheme "EmberMate" \
    -destination "generic/platform=macOS" \
    archive \
    CODE_SIGN_IDENTITY="-" \
    -archivePath "build/EmberMate.xcarchive"
`)

await spinner('Updating exportOptions', () => $`
plutil -convert xml1 - -o "exportOptions.plist" << EOF
    {
        "destination": "export",
        "method": "mac-application"
    }
EOF
`)

await spinner('Exporting Archive', () => $`
xcodebuild \
    -exportArchive \
    -archivePath "build/EmberMate.xcarchive" \
    -exportPath "build" \
    -exportOptionsPlist "exportOptions.plist"
`)

// Remove existing DMGs if they exists
await $`rm -f ./EmberMate*.dmg`

await $`create-dmg --dmg-title='EmberMate' 'build/EmberMate.app' ./`