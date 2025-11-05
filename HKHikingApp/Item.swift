//
//  Item.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class HikingRoute {
    var id: UUID
    var name: String
    var difficulty: String // Easy/Moderate/Hard
    var length: Double // kilometers
    var estimatedTime: Int // minutes
    var startLocation: String
    var endLocation: String
    var routeDescription: String
    var timestamp: Date
    var isFavorite: Bool
    
    // Coordinates for GPS tracking
    var startLatitude: Double
    var startLongitude: Double
    var endLatitude: Double
    var endLongitude: Double
    
    init(name: String, difficulty: String, length: Double, estimatedTime: Int, startLocation: String, endLocation: String, description: String, startLatitude: Double = 0.0, startLongitude: Double = 0.0, endLatitude: Double = 0.0, endLongitude: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.difficulty = difficulty
        self.length = length
        self.estimatedTime = estimatedTime
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.routeDescription = description
        self.timestamp = Date()
        self.isFavorite = false
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
    }
    
    // Helper computed properties
    var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
    }
    
    var endCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude)
    }
    
    var startCLLocation: CLLocation {
        CLLocation(latitude: startLatitude, longitude: startLongitude)
    }
    
    var endCLLocation: CLLocation {
        CLLocation(latitude: endLatitude, longitude: endLongitude)
    }
}
