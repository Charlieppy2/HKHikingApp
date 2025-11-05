//
//  LocationManager.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var speed: Double = 0.0 // m/s
    @Published var altitude: Double = 0.0 // meters
    @Published var heading: Double = 0.0 // degrees
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking = false
    
    // Tracked route points
    @Published var trackedRoute: [CLLocation] = []
    @Published var totalDistance: Double = 0.0 // meters
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0.0
    
    // Statistics
    @Published var averageSpeed: Double = 0.0 // km/h
    @Published var maxSpeed: Double = 0.0 // km/h
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update every 5 meters
        locationManager.activityType = .fitness
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        isTracking = true
        startTime = Date()
        trackedRoute.removeAll()
        totalDistance = 0.0
        maxSpeed = 0.0
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func pauseTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func resumeTracking() {
        if isTracking {
            locationManager.startUpdatingLocation()
        }
    }
    
    func resetTracking() {
        stopTracking()
        trackedRoute.removeAll()
        totalDistance = 0.0
        maxSpeed = 0.0
        elapsedTime = 0.0
        startTime = nil
    }
    
    func updateElapsedTime() {
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        location = newLocation
        speed = newLocation.speed
        altitude = newLocation.altitude
        heading = newLocation.course
        
        if isTracking {
            if let lastLocation = trackedRoute.last {
                let distance = newLocation.distance(from: lastLocation)
                totalDistance += distance
            }
            trackedRoute.append(newLocation)
            
            // Update speed statistics
            let speedKmh = speed * 3.6
            if speedKmh > maxSpeed {
                maxSpeed = speedKmh
            }
            
            // Calculate average speed
            if totalDistance > 0 && elapsedTime > 0 {
                averageSpeed = (totalDistance / 1000.0) / (elapsedTime / 3600.0)
            }
        }
        
        updateElapsedTime()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
