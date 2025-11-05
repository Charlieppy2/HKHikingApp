//
//  TrackingView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import MapKit
import SwiftData
import CoreLocation
import UIKit

struct TrackingView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HikingRoute.timestamp, order: .reverse) private var routes: [HikingRoute]
    
    @State private var selectedRoute: HikingRoute?
    @State private var showingRoutePicker = false
    @State private var isOffRoute = false
    @State private var offRouteDistance: Double = 0.0
    @State private var timer: Timer?
    @State private var currentTrackRecord: TrackRecord?
    @State private var routePath: [CLLocationCoordinate2D] = []
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694), // Hong Kong center
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map view with custom overlay
                MapViewWithOverlays(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    routeAnnotations: routeAnnotations,
                    trackedRoute: locationManager.trackedRoute.map { $0.coordinate },
                    routePath: routePath
                )
                .onChange(of: locationManager.isTracking) { oldValue, newValue in
                    if newValue {
                        userTrackingMode = .followWithHeading
                    } else {
                        userTrackingMode = .none
                    }
                }
                    .overlay(alignment: .top) {
                        // Statistics overlay
                        if locationManager.isTracking {
                            VStack(spacing: 12) {
                                StatsCardView(locationManager: locationManager)
                                
                                // Off-route warning
                                if isOffRoute {
                                    OffRouteWarningView(distance: offRouteDistance)
                                }
                            }
                            .padding()
                        }
                    }
                
                // Bottom control panel
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Route selection
                        if !locationManager.isTracking {
                            Button(action: {
                                showingRoutePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "map")
                                    Text(selectedRoute != nil ? selectedRoute!.name : "Select Route")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Control buttons
                        HStack(spacing: 20) {
                            if locationManager.isTracking {
                                Button(action: {
                                    stopTrackingAndSave()
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "stop.fill")
                                            .font(.title2)
                                        Text("Stop")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    locationManager.pauseTracking()
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "pause.fill")
                                            .font(.title2)
                                        Text("Pause")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            } else {
                                Button(action: {
                                    if locationManager.authorizationStatus == .notDetermined {
                                        locationManager.requestAuthorization()
                                    } else if locationManager.authorizationStatus == .authorizedWhenInUse || 
                                              locationManager.authorizationStatus == .authorizedAlways {
                                        startTracking()
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                            .font(.title2)
                                        Text("Start")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    .background(Color(.systemBackground).opacity(0.95))
                }
            }
            .navigationTitle("GPS Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if locationManager.isTracking {
                        Button("Reset") {
                            locationManager.resetTracking()
                            timer?.invalidate()
                            isOffRoute = false
                        }
                    }
                }
            }
            .onAppear {
                locationManager.requestAuthorization()
                if let location = locationManager.location {
                    region.center = location.coordinate
                }
            }
            .sheet(isPresented: $showingRoutePicker) {
                RoutePickerView(selectedRoute: $selectedRoute, routes: routes)
            }
            .onChange(of: locationManager.location) { oldValue, newValue in
                if let location = newValue {
                    updateRegion()
                    checkOffRoute()
                    updateTrackRecord(location)
                }
            }
            .onChange(of: selectedRoute) { oldValue, newValue in
                if let route = newValue {
                    buildRoutePath(route: route)
                }
            }
            .onAppear {
                if let route = selectedRoute {
                    buildRoutePath(route: route)
                }
            }
        }
    }
    
    private func startTracking() {
        // Create new track record
        currentTrackRecord = TrackRecord(
            routeName: selectedRoute?.name,
            routeId: selectedRoute?.id,
            startTime: Date()
        )
        
        locationManager.startTracking()
        startTimer()
        updateRegion()
    }
    
    private func stopTrackingAndSave() {
        locationManager.stopTracking()
        timer?.invalidate()
        checkOffRoute()
        
        // Save track record
        if var record = currentTrackRecord {
            record.endTime = Date()
            record.totalDistance = locationManager.totalDistance
            record.maxSpeed = locationManager.maxSpeed
            record.averageSpeed = locationManager.averageSpeed
            
            // Calculate elevation stats
            let points = locationManager.trackedRoute
            if !points.isEmpty {
                let altitudes = points.map { $0.altitude }
                record.maxAltitude = altitudes.max() ?? 0.0
                record.minAltitude = altitudes.min() ?? 0.0
                
                // Calculate elevation gain
                var elevationGain = 0.0
                for i in 1..<points.count {
                    let diff = points[i].altitude - points[i-1].altitude
                    if diff > 0 {
                        elevationGain += diff
                    }
                }
                record.totalElevationGain = elevationGain
            }
            
            // Save track points
            let trackPoints = locationManager.trackedRoute.map { TrackPointData(location: $0) }
            record.saveTrackPoints(trackPoints)
            
            modelContext.insert(record)
            currentTrackRecord = nil
        }
    }
    
    private func updateTrackRecord(_ location: CLLocation) {
        guard var record = currentTrackRecord else { return }
        record.totalDistance = locationManager.totalDistance
        record.maxSpeed = locationManager.maxSpeed
        record.averageSpeed = locationManager.averageSpeed
    }
    
    private func buildRoutePath(route: HikingRoute) {
        // For now, we'll create a simple path between start and end
        // In a full implementation, you'd have waypoints stored in the route
        routePath.removeAll()
        
        if route.startLatitude != 0.0 && route.startLongitude != 0.0 {
            routePath.append(route.startCoordinate)
        }
        
        if route.endLatitude != 0.0 && route.endLongitude != 0.0 {
            routePath.append(route.endCoordinate)
        }
    }
    
    private var routeAnnotations: [RouteAnnotation] {
        var annotations: [RouteAnnotation] = []
        
        if let route = selectedRoute {
            // Add start location marker
            if route.startLatitude != 0.0 && route.startLongitude != 0.0 {
                annotations.append(RouteAnnotation(
                    coordinate: route.startCoordinate,
                    color: .green
                ))
            }
            
            // Add end location marker
            if route.endLatitude != 0.0 && route.endLongitude != 0.0 {
                annotations.append(RouteAnnotation(
                    coordinate: route.endCoordinate,
                    color: .red
                ))
            }
        }
        
        return annotations
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            locationManager.updateElapsedTime()
            checkOffRoute()
        }
    }
    
    private func updateRegion() {
        if let location = locationManager.location {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
    
    private func checkOffRoute() {
        guard let currentLocation = locationManager.location,
              let route = selectedRoute else {
            isOffRoute = false
            return
        }
        
        // Check if route has valid coordinates
        guard route.startLatitude != 0.0 && route.startLongitude != 0.0 else {
            isOffRoute = false
            return
        }
        
        // More precise off-route detection based on route path
        var minDistance = Double.infinity
        
        if !routePath.isEmpty {
            // Calculate distance to nearest point on route path
            for coordinate in routePath {
                let routeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = currentLocation.distance(from: routeLocation)
                minDistance = min(minDistance, distance)
            }
        } else {
            // Fallback to start/end distance check
            let distanceToStart = currentLocation.distance(from: route.startCLLocation)
            minDistance = distanceToStart
            
            if route.endLatitude != 0.0 && route.endLongitude != 0.0 {
                let distanceToEnd = currentLocation.distance(from: route.endCLLocation)
                minDistance = min(minDistance, distanceToEnd)
            }
        }
        
        // Consider off route if more than 200 meters from route
        let offRouteThreshold: Double = 200.0 // meters
        isOffRoute = minDistance > offRouteThreshold
        offRouteDistance = minDistance
    }
}

// Route annotation for map
struct RouteAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: Color
}

// Statistics card overlay
struct StatsCardView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                StatItemView(
                    icon: "figure.walk",
                    value: String(format: "%.2f", locationManager.totalDistance / 1000.0),
                    unit: "km",
                    color: .blue
                )
                
                StatItemView(
                    icon: "speedometer",
                    value: String(format: "%.1f", locationManager.speed * 3.6),
                    unit: "km/h",
                    color: .green
                )
                
                StatItemView(
                    icon: "mountain.2",
                    value: String(format: "%.0f", locationManager.altitude),
                    unit: "m",
                    color: .orange
                )
            }
            
            HStack(spacing: 20) {
                StatItemView(
                    icon: "clock",
                    value: formatTime(locationManager.elapsedTime),
                    unit: "",
                    color: .purple
                )
                
                StatItemView(
                    icon: "arrow.up.right",
                    value: String(format: "%.1f", locationManager.maxSpeed),
                    unit: "km/h max",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct StatItemView: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Off-route warning view
struct OffRouteWarningView: View {
    let distance: Double
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Off Route")
                .fontWeight(.semibold)
            Spacer()
            Text(String(format: "%.0f m", distance))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

// Route picker view
struct RoutePickerView: View {
    @Binding var selectedRoute: HikingRoute?
    let routes: [HikingRoute]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(routes) { route in
                Button(action: {
                    selectedRoute = route
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(route.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(String(format: "%.1f", route.length)) km • \(route.estimatedTime) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedRoute?.id == route.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TrackingView()
        .modelContainer(for: HikingRoute.self, inMemory: true)
}
