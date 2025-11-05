import SwiftUI

struct ContentView: View {
    @StateObject private var trailService = TrailService.shared
    @StateObject private var locationService = LocationService.shared
    
    var body: some View {
        TabView {
            TrailListView()
                .tabItem {
                    Label("路線", systemImage: "map")
                }
            
            TrackingView()
                .tabItem {
                    Label("追蹤", systemImage: "location.fill")
                }
            
            RecordsView()
                .tabItem {
                    Label("記錄", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .onAppear {
            locationService.requestAuthorization()
        }
    }
}

struct RecordsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("我的記錄")
                    .font(.title)
                    .padding()
                
                Text("追蹤記錄功能開發中...")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("記錄")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("權限") {
                    Text("位置權限: 需要允許位置權限以使用 GPS 追蹤功能")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section("關於") {
                    Text("香港行山路線 App")
                    Text("版本 1.0.0")
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    ContentView()
}

