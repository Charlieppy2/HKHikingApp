//
//  TrackingHistoryView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import SwiftData

struct TrackingHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackRecord.startTime, order: .reverse) private var records: [TrackRecord]
    
    var body: some View {
        NavigationStack {
            if records.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No tracking history")
                        .foregroundColor(.gray)
                    Text("Start a GPS tracking session to create records")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(records) { record in
                        NavigationLink {
                            TrackRecordDetailView(record: record)
                        } label: {
                            TrackRecordRowView(record: record)
                        }
                    }
                    .onDelete(perform: deleteRecords)
                }
            }
        }
        .navigationTitle("Tracking History")
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(records[index])
            }
        }
    }
}

struct TrackRecordRowView: View {
    let record: TrackRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.routeName ?? "Untitled Route")
                    .font(.headline)
                Spacer()
                Text(record.startTime, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Label("\(String(format: "%.2f", record.totalDistance / 1000.0)) km", systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(record.formattedDuration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(String(format: "%.1f", record.maxSpeed)) km/h", systemImage: "speedometer")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TrackRecordDetailView: View {
    let record: TrackRecord
    @State private var showingGPXExport = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.routeName ?? "Untitled Route")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(record.startTime, format: .dateTime.weekday().month().day().year().hour().minute())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Statistics grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCardView(
                        icon: "figure.walk",
                        title: "Distance",
                        value: String(format: "%.2f km", record.totalDistance / 1000.0),
                        color: .blue
                    )
                    
                    StatCardView(
                        icon: "clock",
                        title: "Duration",
                        value: record.formattedDuration,
                        color: .purple
                    )
                    
                    StatCardView(
                        icon: "arrow.up.right",
                        title: "Max Speed",
                        value: String(format: "%.1f km/h", record.maxSpeed),
                        color: .red
                    )
                    
                    StatCardView(
                        icon: "speedometer",
                        title: "Avg Speed",
                        value: String(format: "%.1f km/h", record.averageSpeed),
                        color: .green
                    )
                    
                    StatCardView(
                        icon: "mountain.2",
                        title: "Max Altitude",
                        value: String(format: "%.0f m", record.maxAltitude),
                        color: .orange
                    )
                    
                    StatCardView(
                        icon: "arrow.up.circle",
                        title: "Elevation Gain",
                        value: String(format: "%.0f m", record.totalElevationGain),
                        color: .cyan
                    )
                }
                
                // Actions
                Button(action: {
                    showingGPXExport = true
                }) {
                    Label("Export GPX File", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingGPXExport) {
            GPXExportView(record: record)
        }
    }
}

struct StatCardView: View {
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
                .font(.headline)
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

#Preview {
    TrackingHistoryView()
        .modelContainer(for: TrackRecord.self, inMemory: true)
}
