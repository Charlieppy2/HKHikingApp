import Foundation

struct TrackRecord: Identifiable {
    let id: String
    let trailId: String
    let trailName: String?
    let startTime: Date
    var endTime: Date?
    var locations: [TrackPoint]
    var checkIns: [CheckIn]
    var photos: [String]  // Photo URLs
    var distance: Double  // 公里
    var duration: TimeInterval  // 秒
    var averageSpeed: Double  // km/h
    var maxElevation: Double?
    var minElevation: Double?
    
    var isCompleted: Bool {
        return endTime != nil
    }
    
    var durationDisplay: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var distanceDisplay: String {
        return String(format: "%.2f km", distance)
    }
    
    var speedDisplay: String {
        return String(format: "%.1f km/h", averageSpeed)
    }
    
    init(
        id: String = UUID().uuidString,
        trailId: String,
        trailName: String? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        locations: [TrackPoint] = [],
        checkIns: [CheckIn] = [],
        photos: [String] = [],
        distance: Double = 0,
        duration: TimeInterval = 0,
        averageSpeed: Double = 0,
        maxElevation: Double? = nil,
        minElevation: Double? = nil
    ) {
        self.id = id
        self.trailId = trailId
        self.trailName = trailName
        self.startTime = startTime
        self.endTime = endTime
        self.locations = locations
        self.checkIns = checkIns
        self.photos = photos
        self.distance = distance
        self.duration = duration
        self.averageSpeed = averageSpeed
        self.maxElevation = maxElevation
        self.minElevation = minElevation
    }
}

struct TrackPoint: Identifiable, Codable {
    let id: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let timestamp: Date
    let speed: Double?  // m/s
    
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude, elevation: elevation)
    }
    
    init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        elevation: Double? = nil,
        timestamp: Date = Date(),
        speed: Double? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.timestamp = timestamp
        self.speed = speed
    }
}

