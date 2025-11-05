//
//  MapViewWithOverlays.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import MapKit

// Custom polyline classes to distinguish between tracked route and planned route
class TrackedRoutePolyline: MKPolyline {}
class RoutePathPolyline: MKPolyline {}

struct MapViewWithOverlays: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    var showsUserLocation: Bool
    @Binding var userTrackingMode: MapUserTrackingMode
    var routeAnnotations: [RouteAnnotation]
    var trackedRoute: [CLLocationCoordinate2D]
    var routePath: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.userTrackingMode = mapUserTrackingMode(from: userTrackingMode)
        mapView.setRegion(coordinateRegion, animated: false)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.userTrackingMode = mapUserTrackingMode(from: userTrackingMode)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Update annotations
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        for annotation in routeAnnotations {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = annotation.coordinate
            mapView.addAnnotation(pointAnnotation)
        }
        
        // Update overlays
        mapView.removeOverlays(mapView.overlays)
        
        // Add tracked route (blue solid line)
        if trackedRoute.count > 1 {
            let trackedPolyline = TrackedRoutePolyline(coordinates: trackedRoute, count: trackedRoute.count)
            mapView.addOverlay(trackedPolyline, level: .aboveRoads)
        }
        
        // Add route path (green dashed line)
        if routePath.count > 1 {
            let routePolyline = RoutePathPolyline(coordinates: routePath, count: routePath.count)
            mapView.addOverlay(routePolyline, level: .aboveLabels)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func mapUserTrackingMode(from mode: MapUserTrackingMode) -> MKUserTrackingMode {
        switch mode {
        case .none:
            return .none
        case .follow:
            return .follow
        case .followWithHeading:
            return .followWithHeading
        @unknown default:
            return .none
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewWithOverlays
        
        init(_ parent: MapViewWithOverlays) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                // Check overlay type
                if overlay is TrackedRoutePolyline {
                    // Tracked route - blue solid line
                    renderer.strokeColor = .blue
                    renderer.lineWidth = 4
                } else if overlay is RoutePathPolyline {
                    // Route path - green dashed line
                    renderer.strokeColor = .green
                    renderer.lineWidth = 3
                    renderer.lineDashPattern = [10, 5]
                    renderer.alpha = 0.7
                }
                
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "RouteAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            // Find matching annotation to get color
            if let pointAnnotation = annotation as? MKPointAnnotation,
               let routeAnnotation = parent.routeAnnotations.first(where: {
                   $0.coordinate.latitude == pointAnnotation.coordinate.latitude &&
                   $0.coordinate.longitude == pointAnnotation.coordinate.longitude
               }) {
                if let markerView = annotationView as? MKMarkerAnnotationView {
                    markerView.markerTintColor = UIColor(routeAnnotation.color)
                }
            }
            
            return annotationView
        }
    }
}
