import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isTracking: Bool = false
    @Published var trackPoints: [TrackPoint] = []
    
    private var trackingStartTime: Date?
    private var trackingStartLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10  // 每 10 米記錄一次
    }
    
    // 請求位置權限
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 請求始終授權（後台追蹤需要）
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // 開始追蹤
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        isTracking = true
        trackPoints.removeAll()
        trackingStartTime = Date()
        locationManager.startUpdatingLocation()
    }
    
    // 停止追蹤
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    // 暫停追蹤
    func pauseTracking() {
        locationManager.stopUpdatingLocation()
        // 保持 isTracking = true，可以繼續
    }
    
    // 恢復追蹤
    func resumeTracking() {
        if isTracking {
            locationManager.startUpdatingLocation()
        }
    }
    
    // 計算總距離
    func calculateTotalDistance() -> Double {
        guard trackPoints.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        
        for i in 1..<trackPoints.count {
            let prevPoint = trackPoints[i - 1]
            let currentPoint = trackPoints[i]
            
            let prevLocation = CLLocation(
                latitude: prevPoint.latitude,
                longitude: prevPoint.longitude
            )
            let currentLocation = CLLocation(
                latitude: currentPoint.latitude,
                longitude: currentPoint.longitude
            )
            
            totalDistance += prevLocation.distance(from: currentLocation)
        }
        
        return totalDistance / 1000  // 轉換為公里
    }
    
    // 獲取當前追蹤統計
    func getTrackingStats() -> (distance: Double, duration: TimeInterval, averageSpeed: Double) {
        let distance = calculateTotalDistance()
        let duration = trackingStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let averageSpeed = duration > 0 ? (distance / duration) * 3600 : 0  // km/h
        
        return (distance, duration, averageSpeed)
    }
    
    // 清除追蹤記錄
    func clearTracking() {
        trackPoints.removeAll()
        trackingStartTime = nil
        trackingStartLocation = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        
        if isTracking {
            let trackPoint = TrackPoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                elevation: location.altitude,
                timestamp: Date(),
                speed: location.speed >= 0 ? location.speed : nil
            )
            
            trackPoints.append(trackPoint)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

