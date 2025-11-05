# Info.plist Requirements

To use GPS tracking features, you need to add the following keys to your `Info.plist` file:

## Required Keys

Add these keys in Xcode:
1. Open your project in Xcode
2. Select your project target
3. Go to the "Info" tab
4. Add the following keys:

### Location Permissions

```
NSLocationWhenInUseUsageDescription: "This app needs location access to track your hiking routes and show your position on the map."
```

```
NSLocationAlwaysAndWhenInUseUsageDescription: "This app needs location access to track your hiking routes even when the app is in the background."
```

### Optional (for future features)

```
NSCameraUsageDescription: "This app needs camera access to take photos during your hikes."
```

```
NSPhotoLibraryUsageDescription: "This app needs photo library access to save and select hiking photos."
```

## Steps in Xcode

1. In Xcode, right-click on `Info.plist` and select "Open As" > "Source Code"
2. Add the following entries before the closing `</dict>` tag:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track your hiking routes and show your position on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your hiking routes even when the app is in the background.</string>
```

Or use the visual editor:
1. Click the "+" button to add a new key
2. Type "Privacy - Location When In Use Usage Description"
3. Enter the description text

