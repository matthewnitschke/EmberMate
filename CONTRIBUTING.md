# Common Issues

## Asking for bluetooth approval each build

- Go to `System Settings` -> `Privacy & Security` -> `Bluetooth`
- Manually remove "EmberMate" as an allowed application
- Rebuild app, and click "Allow"

This should reset bluetooth permissions and no longer ask

# Localization

User facing strings live in `EmberMate/Localizable.xcstrings`, a Xcode String
Catalog. Xcode currently ships `en`, `de`, `es`, `fr`, `ja`, `pt-BR` and
`zh-Hans`.

## Adding a new language

1. Open `EmberMate.xcodeproj`, select the project, then the `EmberMate` target,
   and add the language under the **Info** tab.
2. Translate the new column in `Localizable.xcstrings`.
3. Add an `InfoPlist.strings` for the language next to the existing ones in
   `EmberMate/<lang>.lproj/`. Those provide the localized Bluetooth permission
   prompts.

## Keeping the catalog in sync

`Text("...")`, `Button("...")`, `String(localized:)` and friends are extracted
into the catalog automatically when building **inside Xcode**. When building
from the command line the extracted strings land in the build directory, so use
`xcstringstool` to merge them back:

```sh
xcodebuild -project EmberMate.xcodeproj -scheme EmberMate \
  -configuration Debug -destination 'platform=macOS' build

TMP=$(xcodebuild -project EmberMate.xcodeproj -scheme EmberMate \
  -configuration Debug -destination 'platform=macOS' \
  -showBuildSettings 2>/dev/null | awk -F' = ' '/ TARGET_TEMP_DIR = /{print $2}')

/Applications/Xcode.app/Contents/Developer/usr/bin/xcstringstool sync \
  EmberMate/Localizable.xcstrings \
  --stringsdata "$TMP"/Objects-normal/arm64/*.stringsdata
```

Note that `sync` removes keys it cannot find in the source, so only run it after
a successful build.

## Things that are deliberately *not* localized

- Bluetooth device names (`peripheral.name`) - they come from the mug.
- Preset names - they are user editable and persisted in `UserDefaults`.
- The degree symbols (`℃` / `℉`) and `"+"` buttons - they are symbols, not prose.
