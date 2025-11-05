//
//  TrackRecord.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class TrackRecord {
    var id: UUID
    var routeName: String?
    var routeId: UUID?
    var startTime: Date
    var endTime: Date?
    var totalDistance: Double // meters
    var maxSpeed: Double // km/h
    var averageSpeed: Double // km/h
    var maxAltitude: Double // meters
    var minAltitude: Double // meters
    var totalElevationGain: Double // meters
    var trackPointsData: Data? // Stored as JSON encoded data
    
    init(routeName: String? = nil, routeId: UUID? = nil, startTime: Date = Date()) {
        self.id = UUID()
        self.routeName = routeName
        self.routeId = routeId
        self.startTime = startTime
        self.endTime = nil
        self.totalDistance = 0.0
        self.maxSpeed = 0.0
        self.averageSpeed = 0.0
        self.maxAltitude = 0.0
        self.minAltitude = 0.0
        self.totalElevationGain = 0.0
        self.trackPointsData = nil
    }
    
    // Computed properties
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Convert track points from Data
    func getTrackPoints() -> [TrackPointData] {
        guard let data = trackPointsData,
              let decoded = try? JSONDecoder().decode([TrackPointData].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // Save track points
    func saveTrackPoints(_ points: [TrackPointData]) {
        if let encoded = try? JSONEncoder().encode(points) {
            self.trackPointsData = encoded
        }
    }
    
    // Computed property for SwiftData compatibility
    var trackPoints: [TrackPointData] {
        get { getTrackPoints() }
        set { saveTrackPoints(newValue) }
    }
    
    // Get CLLocation array for map rendering
    func getCLLocations() -> [CLLocation] {
        return trackPoints.map { point in
            CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),
                altitude: point.altitude,
                horizontalAccuracy: 0,
                verticalAccuracy: 0,
                timestamp: point.timestamp
            )
        }
    }
}

// Track point data structure
struct TrackPointData: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    var speed: Double? // m/s
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
        self.speed = location.speed >= 0 ? location.speed : nil
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            timestamp: timestamp
        )
    }
}
