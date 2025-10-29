import Foundation

struct Trail: Identifiable, Codable {
    let id: String
    let name: String
    let nameEn: String?
    let region: String              // 地區
    let district: String?          // 區（如：黃大仙區）
    let distance: Double            // 公里
    let estimatedTime: Int         // 分鐘
    let difficulty: Difficulty     // 難度
    let elevation: Int?            // 海拔（米）
    let startLocation: Coordinate
    let endLocation: Coordinate?
    let waypoints: [Coordinate]    // 路線點
    let facilities: [String]        // 設施
    let description: String
    let tips: [String]             // 提示
    let warnings: [String]         // 警告
    let imageUrl: String?
    let createdAt: Date
    
    // 格式化距離顯示
    var distanceDisplay: String {
        return String(format: "%.1f km", distance)
    }
    
    // 格式化時間顯示
    var timeDisplay: String {
        let hours = estimatedTime / 60
        let minutes = estimatedTime % 60
        if hours > 0 {
            return "\(hours)小時\(minutes > 0 ? "\(minutes)分鐘" : "")"
        }
        return "\(minutes)分鐘"
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        nameEn: String? = nil,
        region: String,
        district: String? = nil,
        distance: Double,
        estimatedTime: Int,
        difficulty: Difficulty,
        elevation: Int? = nil,
        startLocation: Coordinate,
        endLocation: Coordinate? = nil,
        waypoints: [Coordinate] = [],
        facilities: [String] = [],
        description: String = "",
        tips: [String] = [],
        warnings: [String] = [],
        imageUrl: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.region = region
        self.district = district
        self.distance = distance
        self.estimatedTime = estimatedTime
        self.difficulty = difficulty
        self.elevation = elevation
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.waypoints = waypoints
        self.facilities = facilities
        self.description = description
        self.tips = tips
        self.warnings = warnings
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }
}

// 示例數據（用於測試）
extension Trail {
    static let sampleTrails: [Trail] = [
        Trail(
            name: "獅子山",
            region: "新界",
            district: "黃大仙區",
            distance: 5.2,
            estimatedTime: 150,
            difficulty: .medium,
            elevation: 495,
            startLocation: Coordinate(latitude: 22.3344, longitude: 114.1953),
            endLocation: Coordinate(latitude: 22.3456, longitude: 114.2056),
            facilities: ["洗手間", "休息點"],
            description: "獅子山是香港著名的行山路線，可俯瞰九龍半島美景。",
            tips: ["建議早晨出發", "帶備足夠飲用水"],
            warnings: ["部分路段較陡峭", "注意防曬"]
        ),
        Trail(
            name: "太平山山頂徑",
            region: "香港島",
            district: "中西區",
            distance: 3.8,
            estimatedTime: 90,
            difficulty: .easy,
            elevation: 552,
            startLocation: Coordinate(latitude: 22.2719, longitude: 114.1468),
            endLocation: Coordinate(latitude: 22.2719, longitude: 114.1468),
            facilities: ["洗手間", "餐廳", "纜車站"],
            description: "太平山頂徑輕鬆易行，適合初學者，可欣賞維港景色。",
            tips: ["可乘坐纜車上山", "建議黃昏時分欣賞夜景"],
            warnings: []
        )
    ]
}

