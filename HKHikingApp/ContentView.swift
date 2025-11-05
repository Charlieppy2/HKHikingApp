//
//  ContentView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HikingRoute.timestamp, order: .reverse) private var routes: [HikingRoute]
    @State private var searchText = ""
    @State private var selectedDifficulty: String? = nil
    @State private var showingAddRoute = false
    
    var filteredRoutes: [HikingRoute] {
        var result = routes
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { route in
                route.name.localizedCaseInsensitiveContains(searchText) ||
                route.startLocation.localizedCaseInsensitiveContains(searchText) ||
                route.endLocation.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Difficulty filter
        if let difficulty = selectedDifficulty {
            result = result.filter { $0.difficulty == difficulty }
        }
        
        return result
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                // Search bar and filters
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    // Difficulty filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "All", isSelected: selectedDifficulty == nil) {
                                selectedDifficulty = nil
                            }
                            FilterChip(title: "Easy", isSelected: selectedDifficulty == "Easy") {
                                selectedDifficulty = "Easy"
                            }
                            FilterChip(title: "Moderate", isSelected: selectedDifficulty == "Moderate") {
                                selectedDifficulty = "Moderate"
                            }
                            FilterChip(title: "Hard", isSelected: selectedDifficulty == "Hard") {
                                selectedDifficulty = "Hard"
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Route list
                if filteredRoutes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(searchText.isEmpty ? "No hiking routes yet" : "No routes found")
                            .foregroundColor(.gray)
                        if searchText.isEmpty {
                            Button(action: { showingAddRoute = true }) {
                                Label("Add First Route", systemImage: "plus.circle.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredRoutes) { route in
                            NavigationLink {
                                RouteDetailView(route: route)
                            } label: {
                                RouteRowView(route: route)
                            }
                        }
                        .onDelete(perform: deleteRoutes)
                    }
                }
            }
            .navigationTitle("Hiking Routes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddRoute = true }) {
                        Label("Add Route", systemImage: "plus")
                    }
                }
            }
                            .sheet(isPresented: $showingAddRoute) {
                AddRouteView()
            }
        } detail: {
            Text("Select a route")
                .foregroundColor(.secondary)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                NavigationLink(destination: TrackingView()) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: TrackingHistoryView()) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func deleteRoutes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredRoutes[index])
            }
        }
    }
}

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search routes...", text: $text)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// 筛选芯片组件
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

// 路线行视图
struct RouteRowView: View {
    let route: HikingRoute
    
    var difficultyColor: Color {
        switch route.difficulty {
        case "Easy":
            return .green
        case "Moderate":
            return .orange
        case "Hard":
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Difficulty indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(difficultyColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(route.name)
                        .font(.headline)
                    if route.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 16) {
                    Label("\(String(format: "%.1f", route.length)) km", systemImage: "figure.walk")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(route.estimatedTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(route.startLocation) → \(route.endLocation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(route.difficulty)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(difficultyColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(difficultyColor.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HikingRoute.self, configurations: config)
    
    // Sample data
    let sampleRoute1 = HikingRoute(
        name: "Dragon's Back",
        difficulty: "Moderate",
        length: 8.5,
        estimatedTime: 240,
        startLocation: "To Tei Wan",
        endLocation: "Big Wave Bay",
        description: "Dragon's Back is one of Hong Kong's most famous hiking trails, offering stunning coastal and mountain views along the way.",
        startLatitude: 22.2368,
        startLongitude: 114.2608,
        endLatitude: 22.2414,
        endLongitude: 114.2497
    )
    
    let sampleRoute2 = HikingRoute(
        name: "MacLehose Trail Section 1",
        difficulty: "Easy",
        length: 10.6,
        estimatedTime: 180,
        startLocation: "Pak Tam Chung",
        endLocation: "Long Ke",
        description: "A beginner-friendly route with good trail conditions and beautiful scenery.",
        startLatitude: 22.3700,
        startLongitude: 114.3300,
        endLatitude: 22.3700,
        endLongitude: 114.3400
    )
    
    let sampleRoute3 = HikingRoute(
        name: "Tai Mo Shan",
        difficulty: "Hard",
        length: 12.0,
        estimatedTime: 360,
        startLocation: "Tsuen Wan",
        endLocation: "Tai Mo Shan Peak",
        description: "Hong Kong's highest peak, a challenging route for experienced hikers.",
        startLatitude: 22.3700,
        startLongitude: 114.1200,
        endLatitude: 22.4100,
        endLongitude: 114.1230
    )
    
    sampleRoute1.isFavorite = true
    
    container.mainContext.insert(sampleRoute1)
    container.mainContext.insert(sampleRoute2)
    container.mainContext.insert(sampleRoute3)
    
    return ContentView()
        .modelContainer(container)
}
