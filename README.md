# app-Prefs
A demo for open system settings in app.

You can open the system settings in App or Today Widget.

Some iOS system action:
---
You can import by Download config in App: [app-Prefs.plist][d77a6d2d]

  [d77a6d2d]: https://raw.githubusercontent.com/ChengLuffy/app-Prefs/config/app-Prefs.plist "Gihub"

title|app-Prefs:/Prefs:
---|---
Battery | root=BATTERY_USAGE
General | root=General
Storage | root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE
Mobile Data | root=MOBILE_DATA_SETTINGS_ID
WLAN | root=WIFI
Bluetooth | root=Bluetooth
Location Services | root=Privacy&path=LOCATION
Accessibility | root=General&path=ACCESSIBILITY
About | root=General&path=About
Keyboards | root=General&path=Keyboard
Display&Brightness | root=DISPLAY
Sounds | root=Sounds
iTunes&App Stores | root=STORE
Wallpaper | root=Wallpaper
iCloud| root=CASTLE
iCloud Storage | root=CASTLE&path=STORAGE_AND_BACKUP
Personal Hotspot | root=INTERNET_TETHERING
VPN| root=General&path=VPN
Software Update | root=General&path=SOFTWARE_UPDATE_LINK
Profiles&Device Management | root=General&path=ManagedConfigurationList
Reset | root=General&path=Reset
Photos&Camera | root=Photos
Phone | root=Phone
Notifications | root=NOTIFICATIONS_ID
Notes | root=NOTES
Music | root=MUSIC
Language&Regin | root=General&path=INTERNATIONAL
Date & Time | root=General&path=DATE_AND_TIME
