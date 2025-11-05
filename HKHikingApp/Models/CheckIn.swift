import Foundation

struct CheckIn: Identifiable, Codable {
    let id: String
    let trailId: String
    let location: Coordinate
    let type: CheckInType
    let photoUrl: String?
    let timestamp: Date
    let note: String?
    
    init(
        id: String = UUID().uuidString,
        trailId: String,
        location: Coordinate,
        type: CheckInType,
        photoUrl: String? = nil,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.trailId = trailId
        self.location = location
        self.type = type
        self.photoUrl = photoUrl
        self.timestamp = timestamp
        self.note = note
    }
}

enum CheckInType: String, Codable {
    case start = "起點"
    case waypoint = "中途點"
    case end = "終點"
    case landmark = "地標"
    
    var icon: String {
        switch self {
        case .start: return "🚩"
        case .waypoint: return "📍"
        case .end: return "🏁"
        case .landmark: return "🗺️"
        }
    }
}

