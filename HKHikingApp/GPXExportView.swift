//
//  GPXExportView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import UIKit

struct GPXExportView: View {
    let record: TrackRecord
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Export GPX File")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Export your tracking data as a GPX file that can be shared or imported into other apps.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Route", value: record.routeName ?? "Untitled")
                    InfoRow(label: "Distance", value: String(format: "%.2f km", record.totalDistance / 1000.0))
                    InfoRow(label: "Duration", value: record.formattedDuration)
                    InfoRow(label: "Track Points", value: "\(record.trackPoints.count)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Button(action: {
                    exportGPX()
                }) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Exporting..." : "Export GPX")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(isExporting)
                
                if let error = exportError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export GPX")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportGPX() {
        isExporting = true
        exportError = nil
        
        let gpxContent = generateGPX()
        
        // Save to temporary file
        let fileName = "\(record.routeName ?? "Track")_\(record.startTime.formatted(date: .numeric, time: .omitted)).gpx"
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try gpxContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Share the file
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                
                // For iPad support
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    rootViewController.present(activityVC, animated: true)
                }
            }
            
            isExporting = false
        } catch {
            exportError = "Failed to export: \(error.localizedDescription)"
            isExporting = false
        }
    }
    
    private func generateGPX() -> String {
        let points = record.getTrackPoints()
        
        var gpx = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        gpx += "<gpx version=\"1.1\" creator=\"HKHikingApp\">\n"
        gpx += "  <metadata>\n"
        gpx += "    <name>\(record.routeName ?? "Untitled Route")</name>\n"
        gpx += "    <time>\(ISO8601DateFormatter().string(from: record.startTime))</time>\n"
        gpx += "  </metadata>\n"
        gpx += "  <trk>\n"
        gpx += "    <name>\(record.routeName ?? "Untitled Route")</name>\n"
        gpx += "    <trkseg>\n"
        
        for point in points {
            gpx += "      <trkpt lat=\"\(point.latitude)\" lon=\"\(point.longitude)\">\n"
            gpx += "        <ele>\(point.altitude)</ele>\n"
            gpx += "        <time>\(ISO8601DateFormatter().string(from: point.timestamp))</time>\n"
            if let speed = point.speed {
                gpx += "        <extensions><speed>\(speed)</speed></extensions>\n"
            }
            gpx += "      </trkpt>\n"
        }
        
        gpx += "    </trkseg>\n"
        gpx += "  </trk>\n"
        gpx += "</gpx>"
        
        return gpx
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    GPXExportView(record: TrackRecord(routeName: "Test Route"))
}
