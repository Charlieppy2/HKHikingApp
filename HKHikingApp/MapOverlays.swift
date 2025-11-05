//
//  MapOverlays.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import MapKit

// Tracked route overlay (user's actual path)
struct TrackedRouteOverlay: View {
    let route: [CLLocationCoordinate2D]
    
    var body: some View {
        MapPolyline(coordinates: route)
            .stroke(Color.blue, lineWidth: 4)
    }
}

// Route path overlay (planned route)
struct RoutePathOverlay: View {
    let path: [CLLocationCoordinate2D]
    
    var body: some View {
        MapPolyline(coordinates: path)
            .stroke(Color.green.opacity(0.6), style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
    }
}

// MapPolyline view helper
struct MapPolyline: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    let color: UIColor
    let lineWidth: CGFloat
    let lineDashPattern: [NSNumber]?
    
    init(coordinates: [CLLocationCoordinate2D],
         color: UIColor = .blue,
         lineWidth: CGFloat = 3,
         lineDashPattern: [NSNumber]? = nil) {
        self.coordinates = coordinates
        self.color = color
        self.lineWidth = lineWidth
        self.lineDashPattern = lineDashPattern
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)
        
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
            
            // Fit map to show all coordinates
            let rect = polyline.boundingMapRect
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapPolyline
        
        init(_ parent: MapPolyline) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = parent.color
                renderer.lineWidth = parent.lineWidth
                if let dashPattern = parent.lineDashPattern {
                    renderer.lineDashPattern = dashPattern
                }
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// Extension to create MapPolyline with stroke style
extension MapPolyline {
    init(coordinates: [CLLocationCoordinate2D], color: Color, lineWidth: CGFloat, style: StrokeStyle) {
        self.coordinates = coordinates
        self.color = UIColor(color)
        self.lineWidth = CGFloat(lineWidth)
        
        // Convert SwiftUI StrokeStyle dash pattern to NSNumber array
        if let dashPattern = style.dash {
            self.lineDashPattern = dashPattern.map { NSNumber(value: Double($0)) }
        } else {
            self.lineDashPattern = nil
        }
    }
}
