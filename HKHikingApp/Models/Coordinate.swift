import Foundation
import CoreLocation

struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    
    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocationWithElevation: CLLocation {
        let location = CLLocation(coordinate: clLocation, altitude: elevation ?? 0)
        return location
    }
    
    init(latitude: Double, longitude: Double, elevation: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
    
    // 計算兩點間距離（米）
    func distance(to other: Coordinate) -> Double {
        let loc1 = clLocationWithElevation
        let loc2 = other.clLocationWithElevation
        return loc1.distance(from: loc2)
    }
}

