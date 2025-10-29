import Foundation

class TrailService: ObservableObject {
    static let shared = TrailService()
    
    @Published var trails: [Trail] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private init() {
        // 初始化時載入本地數據或從 API 獲取
        loadTrails()
    }
    
    // 載入路線數據
    func loadTrails() {
        isLoading = true
        
        // TODO: 實際實現時從康文署 API 獲取
        // 目前使用示例數據
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.trails = Trail.sampleTrails
            self.isLoading = false
        }
    }
    
    // 從 API 獲取路線（需要實現）
    func fetchTrailsFromAPI() async throws -> [Trail] {
        // 康文署 API URL
        // let url = URL(string: "https://data.gov.hk/...")!
        // let (data, _) = try await URLSession.shared.data(from: url)
        // let response = try JSONDecoder().decode(TrailAPIResponse.self, from: data)
        // return response.result.records
        
        // 暫時返回示例數據
        return Trail.sampleTrails
    }
    
    // 根據 ID 獲取路線
    func getTrail(by id: String) -> Trail? {
        return trails.first { $0.id == id }
    }
    
    // 篩選路線
    func filterTrails(
        difficulty: Difficulty? = nil,
        region: String? = nil,
        maxDistance: Double? = nil
    ) -> [Trail] {
        return trails.filter { trail in
            var matches = true
            
            if let difficulty = difficulty {
                matches = matches && trail.difficulty == difficulty
            }
            
            if let region = region {
                matches = matches && trail.region == region
            }
            
            if let maxDistance = maxDistance {
                matches = matches && trail.distance <= maxDistance
            }
            
            return matches
        }
    }
    
    // 獲取附近的路線（基於位置）
    func getNearbyTrails(from location: Coordinate, radius: Double = 10000) -> [Trail] {
        return trails.filter { trail in
            let distance = location.distance(to: trail.startLocation)
            return distance <= radius
        }.sorted { trail1, trail2 in
            let dist1 = location.distance(to: trail1.startLocation)
            let dist2 = location.distance(to: trail2.startLocation)
            return dist1 < dist2
        }
    }
}

