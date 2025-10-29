import SwiftUI
import MapKit

struct TrailDetailView: View {
    let trail: Trail
    @State private var region: MKCoordinateRegion
    
    init(trail: Trail) {
        self.trail = trail
        _region = State(initialValue: MKCoordinateRegion(
            center: trail.startLocation.clLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 路線基本信息
                VStack(alignment: .leading, spacing: 12) {
                    Text(trail.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(trail.difficulty.starDisplay, systemImage: "star.fill")
                            .foregroundColor(trail.difficulty.color)
                        
                        Spacer()
                        
                        Label(trail.region, systemImage: "location.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Divider()
                    
                    HStack {
                        InfoCard(
                            icon: "ruler",
                            title: "距離",
                            value: trail.distanceDisplay
                        )
                        
                        InfoCard(
                            icon: "clock",
                            title: "時間",
                            value: trail.timeDisplay
                        )
                        
                        if let elevation = trail.elevation {
                            InfoCard(
                                icon: "mountain.2",
                                title: "海拔",
                                value: "\(elevation)m"
                            )
                        }
                    }
                }
                .padding()
                
                // 地圖預覽
                Map(coordinateRegion: $region, annotationItems: [trail]) { trail in
                    MapMarker(
                        coordinate: trail.startLocation.clLocation,
                        tint: .blue
                    )
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // 路線描述
                if !trail.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("路線描述")
                            .font(.headline)
                        Text(trail.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // 設施
                if !trail.facilities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("設施")
                            .font(.headline)
                        FlowLayout(items: trail.facilities) { facility in
                            Label(facility, systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .padding(8)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                // 提示和警告
                if !trail.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 提示")
                            .font(.headline)
                        ForEach(trail.tips, id: \.self) { tip in
                            Text("• \(tip)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if !trail.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ 注意事項")
                            .font(.headline)
                        ForEach(trail.warnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .font(.body)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // 開始按鈕
                NavigationLink(destination: TrackingView(selectedTrail: trail)) {
                    HStack {
                        Spacer()
                        Text("開始行山")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(trail.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FlowLayout: View {
    let items: [String]
    let itemBuilder: (String) -> AnyView
    
    init(items: [String], @ViewBuilder itemBuilder: @escaping (String) -> some View) {
        self.items = items
        self.itemBuilder = { AnyView(itemBuilder($0)) }
    }
    
    var body: some View {
        // 簡單實現，可以改進為真正的 Flow Layout
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { item in
                itemBuilder(item)
            }
        }
    }
}

#Preview {
    NavigationView {
        TrailDetailView(trail: Trail.sampleTrails[0])
    }
}

