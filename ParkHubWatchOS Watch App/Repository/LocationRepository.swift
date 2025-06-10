//
//  LocationRepository.swift
//  ParkHubWatchOS Watch App
//
//  Created by student on 10/06/25.
//

import Foundation

// A new struct to decode the entire JSON response from the REST API
struct AllLocationsResponse: Codable {
    let bukit: [Location?] // Use optional to handle nulls in the bukit array
    let gedung: [String: Location] // Gedung is a dictionary
    let lapangan: [Location]
}

class LocationRepository {
    
    // IMPORTANT: Replace this with your actual Firebase Project ID
    // You can find it in your GoogleService-Info.plist file under "PROJECT_ID"
    // or in the Firebase Console project settings.
    private let projectID = "parkhub-d9c0e"
    
    private var databaseURL: URL? {
        // The .json extension is required for the REST API
        URL(string: "https://parkhub-d9c0e-default-rtdb.asia-southeast1.firebasedatabase.app/locations.json")
    }

    /// Fetches all location data at once using the Firebase REST API.
    /// This is a one-time fetch, not a real-time listener.
    func fetchAllLocations() async throws -> AllLocationsResponse {
        guard let url = databaseURL else {
            throw URLError(.badURL)
        }
        
        print("Fetching data from: \(url)")
        
        // Make the network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON data into our response struct
        let decodedResponse = try JSONDecoder().decode(AllLocationsResponse.self, from: data)
        return decodedResponse
    }
    
    // The real-time observers are no longer needed and will not work on watchOS.
    // You can delete them or leave them here for reference.
    func removeAllObservers() {
        // This method is now empty as we have no persistent observers.
    }
    
    deinit {
        removeAllObservers()
    }
}


// The Mock Repository is now EVEN MORE IMPORTANT for UI development.
// It doesn't need any changes.
class MockLocationRepository: LocationRepository {
    override func fetchAllLocations() async throws -> AllLocationsResponse {
        // Simulate a network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create mock bukit data
        var bukit: [Location] = []
        for i in 1...36 {
            let isSpotFilled = (i % 5 == 0) || (i > 30)
            bukit.append(Location(id: i, nama: "Bukit-\(i)", isFilled: isSpotFilled))
        }

        // Create mock lapangan data
        var lapangan: [Location] = []
        for i in 0..<281 {
            let isSpotFilled = (i % 10 == 0)
            lapangan.append(Location(id: i, nama: "Lapangan-\(i)", isFilled: isSpotFilled))
        }

        // Create mock gedung data (as a dictionary, like the real response)
        var gedung: [String: Location] = [:]
        for floor in 3...14 {
            let isEvenFloor = (floor % 2 == 0)
            let numberOfSpots = isEvenFloor ? 36 : 39
            for spotNumber in 1...numberOfSpots {
                let locationId = floor * 100 + spotNumber
                let locationName = "Gedung-\(floor)-\(spotNumber)"
                let isSpotFilled = (spotNumber % 7 == 0)
                let location = Location(id: locationId, nama: locationName, isFilled: isSpotFilled)
                gedung["ID-\(locationId)"] = location // Use a string key
            }
        }
        
        return AllLocationsResponse(bukit: bukit, gedung: gedung, lapangan: lapangan)
    }
}
