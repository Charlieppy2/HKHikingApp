import SwiftUI

struct TrailListView: View {
    @StateObject private var trailService = TrailService.shared
    @State private var searchText = ""
    @State private var selectedDifficulty: Difficulty?
    @State private var selectedRegion: String?
    
    var filteredTrails: [Trail] {
        var trails = trailService.trails
        
        // 搜索過濾
        if !searchText.isEmpty {
            trails = trails.filter { trail in
                trail.name.localizedCaseInsensitiveContains(searchText) ||
                (trail.nameEn?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 難度過濾
        if let difficulty = selectedDifficulty {
            trails = trails.filter { $0.difficulty == difficulty }
        }
        
        // 地區過濾
        if let region = selectedRegion {
            trails = trails.filter { $0.region == region }
        }
        
        return trails
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if trailService.isLoading {
                    ProgressView("載入路線中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredTrails) { trail in
                        NavigationLink(destination: TrailDetailView(trail: trail)) {
                            TrailRowView(trail: trail)
                        }
                    }
                }
            }
            .navigationTitle("行山路線")
            .searchable(text: $searchText, prompt: "搜尋路線")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("難度", selection: $selectedDifficulty) {
                            Text("全部").tag(Difficulty?.none)
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.displayName).tag(Difficulty?.some(difficulty))
                            }
                        }
                        
                        Picker("地區", selection: $selectedRegion) {
                            Text("全部").tag(String?.none)
                            ForEach(["新界", "九龍", "香港島"], id: \.self) { region in
                                Text(region).tag(String?.some(region))
                            }
                        }
                        
                        Button("清除篩選") {
                            selectedDifficulty = nil
                            selectedRegion = nil
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                trailService.loadTrails()
            }
        }
    }
}

struct TrailRowView: View {
    let trail: Trail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trail.name)
                    .font(.headline)
                Spacer()
                Text(trail.difficulty.starDisplay)
                    .font(.caption)
            }
            
            HStack {
                Label(trail.distanceDisplay, systemImage: "ruler")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(trail.timeDisplay, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let district = trail.district {
                Text(district)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TrailListView()
}

