//
//  AddRouteView.swift
//  HKHikingApp
//
//  Created by Charlie on 30/10/2025.
//

import SwiftUI
import SwiftData

struct AddRouteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var difficulty = "Easy"
    @State private var length = ""
    @State private var estimatedTime = ""
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var description = ""
    @State private var startLatitude = ""
    @State private var startLongitude = ""
    @State private var endLatitude = ""
    @State private var endLongitude = ""
    
    let difficulties = ["Easy", "Moderate", "Hard"]
    var isEditMode: Bool = false
    var route: HikingRoute?
    
    init(route: HikingRoute? = nil) {
        self.route = route
        self.isEditMode = route != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Route Name", text: $name)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty).tag(difficulty)
                        }
                    }
                }
                
                Section("Route Details") {
                    HStack {
                        TextField("Length", text: $length)
                            .keyboardType(.decimalPad)
                        Text("km")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Estimated Time", text: $estimatedTime)
                            .keyboardType(.numberPad)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Start Location", text: $startLocation)
                    TextField("End Location", text: $endLocation)
                }
                
                Section("Coordinates (Optional)") {
                    HStack {
                        TextField("Start Lat", text: $startLatitude)
                            .keyboardType(.decimalPad)
                        TextField("Start Long", text: $startLongitude)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        TextField("End Lat", text: $endLatitude)
                            .keyboardType(.decimalPad)
                        TextField("End Long", text: $endLongitude)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit Route" : "Add Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoute()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if let route = route {
                    loadRouteData(route)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !length.isEmpty &&
        !estimatedTime.isEmpty &&
        !startLocation.isEmpty &&
        !endLocation.isEmpty &&
        Double(length) != nil &&
        Int(estimatedTime) != nil
    }
    
    private func loadRouteData(_ route: HikingRoute) {
        name = route.name
        difficulty = route.difficulty
        length = String(format: "%.1f", route.length)
        estimatedTime = String(route.estimatedTime)
        startLocation = route.startLocation
        endLocation = route.endLocation
        description = route.routeDescription
        startLatitude = route.startLatitude != 0.0 ? String(route.startLatitude) : ""
        startLongitude = route.startLongitude != 0.0 ? String(route.startLongitude) : ""
        endLatitude = route.endLatitude != 0.0 ? String(route.endLatitude) : ""
        endLongitude = route.endLongitude != 0.0 ? String(route.endLongitude) : ""
    }
    
    private func saveRoute() {
        guard let lengthValue = Double(length),
              let timeValue = Int(estimatedTime) else {
            return
        }
        
        let startLat = Double(startLatitude) ?? 0.0
        let startLng = Double(startLongitude) ?? 0.0
        let endLat = Double(endLatitude) ?? 0.0
        let endLng = Double(endLongitude) ?? 0.0
        
        if let route = route {
            // Edit existing route
            route.name = name
            route.difficulty = difficulty
            route.length = lengthValue
            route.estimatedTime = timeValue
            route.startLocation = startLocation
            route.endLocation = endLocation
            route.routeDescription = description
            route.startLatitude = startLat
            route.startLongitude = startLng
            route.endLatitude = endLat
            route.endLongitude = endLng
        } else {
            // Create new route
            let newRoute = HikingRoute(
                name: name,
                difficulty: difficulty,
                length: lengthValue,
                estimatedTime: timeValue,
                startLocation: startLocation,
                endLocation: endLocation,
                description: description,
                startLatitude: startLat,
                startLongitude: startLng,
                endLatitude: endLat,
                endLongitude: endLng
            )
            modelContext.insert(newRoute)
        }
        
        dismiss()
    }
}

struct EditRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var route: HikingRoute
    
    var body: some View {
        AddRouteView(route: route)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HikingRoute.self, configurations: config)
    
    return AddRouteView()
        .modelContainer(container)
}
