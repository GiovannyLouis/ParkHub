//
//  LocationViewModel.swift
//  ParkHubWatchOS Watch App
//
//  Created by student on 10/06/25.
//

import Foundation
import SwiftUI

@MainActor // Ensures all updates happen on the main thread
class LocationViewModel: ObservableObject {

    // Published properties are the same
    @Published var bukitLocations: [Location] = []
    @Published var lapanganLocations: [Location] = []
    @Published var gedungLocations: [Location] = []
    
    @Published var currentGedungFloor: Int = 3
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let repository: LocationRepository
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    // New function to load all data
    func loadAllLocations() async {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        
        isLoading = true
        errorMessage = nil
        print("ViewModel is starting to fetch all locations...")

        do {
            let response = try await repository.fetchAllLocations()
            
            // Update properties from the response
            self.bukitLocations = response.bukit.compactMap { $0 }.sorted { $0.id < $1.id }
            self.lapanganLocations = response.lapangan.sorted { $0.id < $1.id }
            self.gedungLocations = Array(response.gedung.values).sorted { $0.id < $1.id }
            
            print("Successfully fetched all locations.")
            
        } catch {
            self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            print(errorMessage ?? "Unknown error")
        }
        
        isLoading = false
    }
    
    // MARK: - Universal Helper
    
    func getColor(for location: Location) -> Color {
        return location.isFilled ? .red : .green
    }
    
    // MARK: - BUKIT LOGIC
    
    // Computed Properties for Bukit
    var vertiBukitLocations: [Location] {
        guard bukitLocations.count >= 18 else { return [] }
        return Array(bukitLocations[0..<18])
    }

    var horizBukitLocations: [Location] {
        guard bukitLocations.count >= 36 else { return [] }
        return Array(bukitLocations[18..<36])
    }
    
    // MARK: - LAPANGAN LOGIC
    
    // Computed Properties for Lapangan
    var locations_260_273: [Location] {
        guard lapanganLocations.count > 273 else { return [] }
        return Array(lapanganLocations[260...273])
    }

    var locations_220_259_rev: [Location] {
        guard lapanganLocations.count > 259 else { return [] }
        return Array(lapanganLocations[220...259].reversed())
    }
    
    // ... add all other lapangan location slices here, making sure they use 'lapanganLocations' ...
    var locations_180_219_rev: [Location] {
        guard lapanganLocations.count > 219 else { return [] }
        return Array(lapanganLocations[180...219].reversed())
    }

    var locations_140_179_rev: [Location] {
        guard lapanganLocations.count > 179 else { return [] }
        return Array(lapanganLocations[140...179].reversed())
    }
    
    var locations_274_280: [Location] {
        guard lapanganLocations.count > 280 else { return [] }
        return Array(lapanganLocations[274...280])
    }

    var locations_115_139_rev: [Location] {
        guard lapanganLocations.count > 139 else { return [] }
        return Array(lapanganLocations[115...139].reversed())
    }

    var locations_90_114_rev: [Location] {
        guard lapanganLocations.count > 114 else { return [] }
        return Array(lapanganLocations[90...114].reversed())
    }
    
    var locations_65_89_rev: [Location] {
        guard lapanganLocations.count > 89 else { return [] }
        return Array(lapanganLocations[65...89].reversed())
    }
    
    var locations_40_64: [Location] {
        guard lapanganLocations.count > 64 else { return [] }
        return Array(lapanganLocations[40...64])
    }

    var locations_0_39: [Location] {
        guard lapanganLocations.count > 39 else { return [] }
        return Array(lapanganLocations[0...39])
    }

    // MARK: - GEDUNG LOGIC
    
    private let minGedungFloor = 3
    private let maxGedungFloor = 14
    
    // Methods for Gedung
    func incrementGedungFloor() {
        if currentGedungFloor < maxGedungFloor {
            currentGedungFloor += 1
        }
    }

    func decrementGedungFloor() {
        if currentGedungFloor > minGedungFloor {
            currentGedungFloor -= 1
        }
    }

    // Computed Properties for Gedung
    var isCurrentGedungFloorEven: Bool {
        currentGedungFloor % 2 == 0
    }

    var filteredGedungsForCurrentFloor: [Location] {
        gedungLocations.filter { location in
            let floorOfLocation = location.id / 100
            return floorOfLocation == currentGedungFloor
        }
    }
    
    var evenFloorLeftSectionSpots: [Location] {
        guard isCurrentGedungFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        return Array(filteredGedungsForCurrentFloor[18...35])
    }

    var oddFloorLeftSectionSpots: [Location] {
        guard !isCurrentGedungFloorEven, filteredGedungsForCurrentFloor.count == 39 else { return [] }
        return Array(filteredGedungsForCurrentFloor[0...20].reversed())
    }
    
    var evenFloorRightSectionSpotsTop: [Location] {
        guard isCurrentGedungFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        return Array(filteredGedungsForCurrentFloor[0...13])
    }
    
    var evenFloorRightSectionSpotsBottom: [Location] {
        guard isCurrentGedungFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        return Array(filteredGedungsForCurrentFloor[14...17])
    }

    var oddFloorRightSectionSpots: [Location] {
        guard !isCurrentGedungFloorEven, filteredGedungsForCurrentFloor.count == 39 else { return [] }
        return Array(filteredGedungsForCurrentFloor[21...38])
    }
}
