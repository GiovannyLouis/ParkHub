
import SwiftUI // For Color

class BukitViewModel: ObservableObject {
    @Published var locations: [Location] = []
    
    init() {
        loadBukitLocations()
    }
    
    func loadBukitLocations() {
        var tempLocations: [Location] = []
        for i in 1...36 {
            // For demonstration, let's make some filled and some not
            // You can adjust this logic or fetch real data later
            let isSpotFilled = (i % 5 == 0) || (i > 30) // Example: every 5th and last 6 are filled
            tempLocations.append(Location(id: i, nama: "Bukit-\(i)", isFilled: isSpotFilled))
        }
        self.locations = tempLocations
    }
    
    func getColor(for location: Location) -> Color {
        return location.isFilled ? .red : .green
    }
    
    var vertiBukitLocations: [Location] {
        guard locations.count >= 18 else { return [] }
        return Array(locations[0..<18])
    }

    var horizBukitLocations: [Location] {
        guard locations.count >= 36 else { return [] }
        return Array(locations[18..<36])
    }
}

class LapanganViewModel: ObservableObject {
    @Published var locations: [Location] = []
    private let totalLapanganSpots = 281 // Max index 280, so 281 items (0-280)

    init() {
        loadLapanganLocations()
    }

    func loadLapanganLocations() {
        var tempLocations: [Location] = []
        for i in 0..<totalLapanganSpots {
            // Example: make some spots filled for demonstration
            // Adjust this logic as needed
            let isSpotFilled = (i % 10 == 0) || (i > 250 && i < 260)
            tempLocations.append(Location(id: i, nama: "Lapangan-\(i)", isFilled: isSpotFilled))
        }
        self.locations = tempLocations
    }

    func getColor(for location: Location) -> Color {
        return location.isFilled ? .red : .green
    }

    // Helper to get specific ranges of locations, matching Compose logic & loop directions
    // Ensure locations array is populated before accessing these.

    // for (i in 260 until 274) -> Verti -> locations[260...273]
    var locations_260_273: [Location] {
        guard locations.count > 273 else { return [] }
        return Array(locations[260...273])
    }

    // for (i in 259 downTo 220) -> Horiz -> locations[220...259].reversed()
    var locations_220_259_rev: [Location] {
        guard locations.count > 259 else { return [] }
        return Array(locations[220...259].reversed())
    }

    // for (i in 219 downTo 180) -> Horiz -> locations[180...219].reversed()
    var locations_180_219_rev: [Location] {
        guard locations.count > 219 else { return [] }
        return Array(locations[180...219].reversed())
    }

    // for (i in 179 downTo 140) -> Horiz -> locations[140...179].reversed()
    var locations_140_179_rev: [Location] {
        guard locations.count > 179 else { return [] }
        return Array(locations[140...179].reversed())
    }
    
    // for (i in 274 until 281) -> Verti -> locations[274...280]
    var locations_274_280: [Location] {
        guard locations.count > 280 else { return [] }
        return Array(locations[274...280])
    }

    // for (i in 139 downTo 115) -> Horiz -> locations[115...139].reversed()
    var locations_115_139_rev: [Location] {
        guard locations.count > 139 else { return [] }
        return Array(locations[115...139].reversed())
    }

    // for (i in 114 downTo 90) -> Horiz -> locations[90...114].reversed()
    var locations_90_114_rev: [Location] {
        guard locations.count > 114 else { return [] }
        return Array(locations[90...114].reversed())
    }

    // for (i in 89 downTo 65) -> Horiz -> locations[65...89].reversed()
    var locations_65_89_rev: [Location] {
        guard locations.count > 89 else { return [] }
        return Array(locations[65...89].reversed())
    }
    
    // for (i in 40 until 65) -> Horiz -> locations[40...64]
    var locations_40_64: [Location] {
        guard locations.count > 64 else { return [] }
        return Array(locations[40...64])
    }

    // for (i in 0 until 40) -> Horiz -> locations[0...39]
    var locations_0_39: [Location] {
        guard locations.count > 39 else { return [] }
        return Array(locations[0...39])
    }
}

class GedungViewModel: ObservableObject {
    @Published var allGedungLocations: [Location] = []
    @Published var currentFloor: Int = 4
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private let minFloor = 3
    private let maxFloor = 14

    init() {
        loadAllGedungLocations()
    }

    func loadAllGedungLocations() {
        self.isLoading = true
        self.errorMessage = nil
        var tempLocations: [Location] = []

        for floor in minFloor...maxFloor {
            let isEvenFloor = (floor % 2 == 0)
            let numberOfSpots = isEvenFloor ? 36 : 39

            for spotNumber in 1...numberOfSpots {
                let locationId = floor * 100 + spotNumber // Unique ID: floor * 100 + spot
                let locationName = "Gedung-\(floor)-\(spotNumber)"
                // Example: make some spots filled for demonstration
                let isSpotFilled = (spotNumber % 7 == 0) || (floor == currentFloor && spotNumber > numberOfSpots - 5)

                tempLocations.append(
                    Location(id: locationId, nama: locationName, isFilled: isSpotFilled)
                )
            }
        }
        self.allGedungLocations = tempLocations
        self.isLoading = false
    }

    func incrementFloor() {
        if currentFloor < maxFloor {
            currentFloor += 1
        }
    }

    func decrementFloor() {
        if currentFloor > minFloor {
            currentFloor -= 1
        }
    }

    var isCurrentFloorEven: Bool {
        currentFloor % 2 == 0
    }

    var filteredGedungsForCurrentFloor: [Location] {
        allGedungLocations.filter { location in
            let floorOfLocation = location.id / 100
            return floorOfLocation == currentFloor
        }
        // The spots should already be in order due to how they were generated (1 to N)
    }

    func getGedungColor(isFilled: Bool) -> Color {
        return isFilled ? .red : .green
    }

    // --- Data Slices for the View ---
    // These computed properties will provide the exact arrays needed by ForEach,
    // handling potential out-of-bounds issues if filteredGedungsForCurrentFloor is unexpectedly short.

    // For Even Floor - Left Section: spots 19-36 (indices 18-35)
    var evenFloorLeftSectionSpots: [Location] {
        guard isCurrentFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        return Array(filteredGedungsForCurrentFloor[18...35])
    }

    // For Odd Floor - Left Section: spots 1-21 (indices 0-20), reversed
    var oddFloorLeftSectionSpots: [Location] {
        guard !isCurrentFloorEven, filteredGedungsForCurrentFloor.count == 39 else { return [] }
        return Array(filteredGedungsForCurrentFloor[0...20].reversed())
    }

    // For Even Floor - Right Section (Top): spots 1-14 (indices 0-13)
    var evenFloorRightSectionSpotsTop: [Location] {
        guard isCurrentFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        return Array(filteredGedungsForCurrentFloor[0...13])
    }
    
    // For Even Floor - Right Section (Bottom): spots 15-18 (indices 14-17)
    var evenFloorRightSectionSpotsBottom: [Location] {
        guard isCurrentFloorEven, filteredGedungsForCurrentFloor.count == 36 else { return [] }
        // Original slice was 14..17, which is 4 spots.
        // If spots are 1-based, this would be spots 15, 16, 17, 18.
        return Array(filteredGedungsForCurrentFloor[14...17])
    }

    // For Odd Floor - Right Section: spots 22-39 (indices 21-38)
    var oddFloorRightSectionSpots: [Location] {
        guard !isCurrentFloorEven, filteredGedungsForCurrentFloor.count == 39 else { return [] }
        return Array(filteredGedungsForCurrentFloor[21...38])
    }
}
