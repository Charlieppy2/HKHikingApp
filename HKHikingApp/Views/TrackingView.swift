import SwiftUI
import MapKit
import CoreLocation

struct TrackingView: View {
    let selectedTrail: Trail?
    
    @StateObject private var locationService = LocationService.shared
    @State private var region: MKCoordinateRegion
    @State private var showPhotoPicker = false
    @State private var showCheckIn = false
    
    init(selectedTrail: Trail? = nil) {
        self.selectedTrail = selectedTrail
        if let trail = selectedTrail {
            _region = State(initialValue: MKCoordinateRegion(
                center: trail.startLocation.clLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    var stats: (distance: Double, duration: TimeInterval, averageSpeed: Double) {
        locationService.getTrackingStats()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 地圖視圖
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .onAppear {
                    updateRegion()
                }
                .onChange(of: locationService.currentLocation) { _ in
                    updateRegion()
                }
            
            // 統計資訊
            VStack(spacing: 16) {
                if locationService.isTracking {
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "ruler",
                            value: String(format: "%.2f km", stats.distance),
                            label: "距離"
                        )
                        
                        StatCard(
                            icon: "clock",
                            value: formatDuration(stats.duration),
                            label: "時間"
                        )
                        
                        StatCard(
                            icon: "speedometer",
                            value: String(format: "%.1f", stats.averageSpeed),
                            label: "速度 km/h"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 控制按鈕
                HStack(spacing: 20) {
                    if !locationService.isTracking {
                        Button(action: {
                            locationService.startTracking()
                        }) {
                            Label("開始追蹤", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            locationService.pauseTracking()
                        }) {
                            Label("暫停", systemImage: "pause.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            locationService.stopTracking()
                        }) {
                            Label("結束", systemImage: "stop.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        showCheckIn = true
                    }) {
                        Label("打卡", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
        }
        .navigationTitle("GPS 追蹤")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCheckIn) {
            CheckInView(trail: selectedTrail)
        }
        .onAppear {
            locationService.requestAuthorization()
        }
    }
    
    private func updateRegion() {
        guard let location = locationService.currentLocation else { return }
        withAnimation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CheckInView: View {
    let trail: Trail?
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationService = LocationService.shared
    @State private var checkInType: CheckInType = .waypoint
    @State private var note: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("打卡類型") {
                    Picker("類型", selection: $checkInType) {
                        ForEach([CheckInType.start, .waypoint, .end, .landmark], id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                }
                
                Section("備註") {
                    TextField("輸入備註（選填）", text: $note)
                }
                
                Section("位置") {
                    if let location = locationService.currentLocation {
                        Text("緯度: \(location.coordinate.latitude, specifier: "%.6f")")
                        Text("經度: \(location.coordinate.longitude, specifier: "%.6f")")
                        if location.altitude > 0 {
                            Text("海拔: \(Int(location.altitude))m")
                        }
                    } else {
                        Text("獲取位置中...")
                    }
                }
            }
            .navigationTitle("打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("確認") {
                        // TODO: 保存打卡記錄
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        TrackingView()
    }
}

