<p align="center">
  <img src="EmberMate/Assets.xcassets/AppIcon.appiconset/Icon 256.png" alt="EmberMate" width="128" /> <br /><br />
  <span>Control your <a href="https://ember.com/">ember mug</a>, directly from your MacOS menubar</span>
</p>


# EmberMate

A menubar application for controlling ember mugs

![with-timer](https://github.com/matthewnitschke/EmberMate/assets/6363089/6b37e508-8a57-4129-b1ca-23a09f260f7e)

## Support this project
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/matthewnitschke)

# Installation

- Download the latest `EmberMate.dmg` file from the [Releases](https://github.com/matthewnitschke/EmberMate/releases) page
- Extract the zip file and drag the .app (will be called EmberMate) to your Applications folder
- IMPORTANT! You will get a popup saying that EmberMate cannot be opened. See the below section for why this, but the setting can be overwritten by going to `System Settings` -> `Privacy & Security` -> `Open Anyway`

## Why does apple think EmberMate is malicious software?

<img width="501" alt="NotOpened" src="https://github.com/user-attachments/assets/dbbec166-c407-42ac-a66b-77d2c54b03d4" />

This message is displayed because the `EmberMate` application is not what you would call "signed". Apple charges developers yearly to sign applications, and this is something I do not want to pay for at this time

You can override this by navigating to "System Settings" -> "Privacy & Security" and clicking "Open Anyway" in the Security section

![OpenAnyway](https://github.com/user-attachments/assets/e3304f98-3e88-4289-a799-3df67d26a848)

## Credits

Huge thanks to orlopau and their [ember-mug](https://github.com/orlopau/ember-mug) repo for reverse engineering the ember mug bluetooth api