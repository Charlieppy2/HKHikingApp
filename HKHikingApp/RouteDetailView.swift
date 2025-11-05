//
//  RouteDetailView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import SwiftData

struct RouteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var route: HikingRoute
    @State private var showingEditView = false
    
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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Route name and favorite button
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(route.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(route.difficulty)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(difficultyColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(difficultyColor.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        route.isFavorite.toggle()
                    }) {
                        Image(systemName: route.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(route.isFavorite ? .red : .gray)
                    }
                }
                
                Divider()
                
                // Statistics cards
                HStack(spacing: 20) {
                    InfoCard(
                        icon: "figure.walk",
                        title: "Length",
                        value: "\(String(format: "%.1f", route.length)) km",
                        color: .blue
                    )
                    
                    InfoCard(
                        icon: "clock",
                        title: "Duration",
                        value: "\(route.estimatedTime) min",
                        color: .orange
                    )
                }
                
                // Start and end locations
                VStack(alignment: .leading, spacing: 12) {
                    RouteLocationView(
                        icon: "location.circle.fill",
                        title: "Start",
                        location: route.startLocation,
                        color: .green
                    )
                    
                    RouteLocationView(
                        icon: "mappin.circle.fill",
                        title: "End",
                        location: route.endLocation,
                        color: .red
                    )
                }
                
                // Route description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(route.routeDescription.isEmpty ? "No description" : route.routeDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Created date
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Created: \(route.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditRouteView(route: route)
        }
    }
}

// 信息卡片组件
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// 路线位置组件
struct RouteLocationView: View {
    let icon: String
    let title: String
    let location: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(location)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HikingRoute.self, configurations: config)
    
    let sampleRoute = HikingRoute(
        name: "Dragon's Back",
        difficulty: "Moderate",
        length: 8.5,
        estimatedTime: 240,
        startLocation: "To Tei Wan",
        endLocation: "Big Wave Bay",
        description: "Dragon's Back is one of Hong Kong's most famous hiking trails, offering stunning coastal and mountain views along the way. There are many great photo spots, and it's recommended to visit on a clear day.",
        startLatitude: 22.2368,
        startLongitude: 114.2608,
        endLatitude: 22.2414,
        endLongitude: 114.2497
    )
    
    container.mainContext.insert(sampleRoute)
    
    return NavigationStack {
        RouteDetailView(route: sampleRoute)
    }
    .modelContainer(container)
}
