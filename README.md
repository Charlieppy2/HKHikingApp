# 🥾 HK Hiking App

A comprehensive iOS hiking app for Hong Kong with route management, GPS tracking, and GPX export features.

## ✨ Features

### 📍 Route Management
- Create and manage hiking routes
- Search routes by name, start, or end location
- Filter routes by difficulty (Easy/Moderate/Hard)
- Favorite routes
- Route details with statistics

### 🗺️ GPS Tracking & Navigation
- Real-time GPS location tracking
- Interactive map display using MapKit
- Distance, speed, and altitude statistics
- Off-route detection and alerts
- Route path visualization on map

### 📊 Tracking History
- Save all GPS tracking sessions
- View detailed statistics for each tracking record
- Track distance, duration, speed, elevation gain
- Export tracking data as GPX files

### 📤 GPX Export
- Export tracking data in standard GPX format
- Share GPX files with other apps
- Compatible with popular hiking and mapping applications

## 🛠️ Technology Stack

- **SwiftUI**: Modern UI framework
- **SwiftData**: Data persistence
- **MapKit**: Map display and visualization
- **CoreLocation**: GPS tracking services
- **Combine**: Reactive data flow

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Getting Started

### Prerequisites

1. Install Xcode from the App Store
2. Ensure you have an Apple Developer account (for device testing)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/HKHikingApp.git
cd HKHikingApp
```

2. Open the project in Xcode:
```bash
open HKHikingApp.xcodeproj
```

3. Configure Location Permissions:
   - Open `Info.plist` (or add keys in Xcode's Info tab)
   - Add the following keys:
     - `NSLocationWhenInUseUsageDescription`: "This app needs location access to track your hiking routes and show your position on the map."
     - `NSLocationAlwaysAndWhenInUseUsageDescription`: "This app needs location access to track your hiking routes even when the app is in the background."

4. Build and Run:
   - Select a target device or simulator
   - Press `⌘R` to build and run

## 📱 Usage

### Adding Routes
1. Tap the "+" button in the top right
2. Fill in route details:
   - Route name
   - Difficulty level
   - Length and estimated time
   - Start and end locations
   - Optional coordinates for GPS tracking
   - Description

### GPS Tracking
1. Navigate to the Tracking view
2. Optionally select a route to track
3. Tap "Start" to begin GPS tracking
4. View real-time statistics on the map overlay
5. Tap "Stop" to end tracking and save the record

### Viewing History
1. Access Tracking History from the main navigation
2. View all saved tracking records
3. Tap a record to see detailed statistics
4. Export as GPX from the detail view

## 📂 Project Structure

```
HKHikingApp/
├── HKHikingApp/
│   ├── HKHikingAppApp.swift          # App entry point
│   ├── ContentView.swift             # Main route list view
│   ├── RouteDetailView.swift         # Route details
│   ├── AddRouteView.swift            # Add/Edit route form
│   ├── TrackingView.swift            # GPS tracking interface
│   ├── TrackingHistoryView.swift     # Tracking history list
│   ├── GPXExportView.swift           # GPX export interface
│   ├── LocationManager.swift         # CoreLocation wrapper
│   ├── MapViewWithOverlays.swift     # Custom map with polylines
│   ├── Item.swift                    # HikingRoute data model
│   └── TrackRecord.swift             # Tracking record model
├── .gitignore
└── README.md
```

## 🔐 Permissions

The app requires the following permissions:

- **Location Services**: Required for GPS tracking and map display
  - `NSLocationWhenInUseUsageDescription`
  - `NSLocationAlwaysAndWhenInUseUsageDescription` (optional, for background tracking)

## 📝 License

This project is available for personal use.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Made with ❤️ for Hong Kong hikers
