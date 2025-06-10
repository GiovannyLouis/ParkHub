//
//  LocationRepository.swift
//  ParkHub
//
//  Created by student on 10/06/25.
//

import Foundation
import FirebaseDatabase

class LocationRepository {

    // MARK: - Firebase References
    private let bukitRef = Database.database().reference().child("locations/bukit")
    private let lapanganRef = Database.database().reference().child("locations/lapangan")
    private let gedungRef = Database.database().reference().child("locations/gedung")

    // MARK: - Database Handles
    private var bukitHandle: DatabaseHandle?
    private var lapanganHandle: DatabaseHandle?
    private var gedungHandle: DatabaseHandle?
    
    // MARK: - Observation Methods

    /// Observes "bukit" locations, decoding the data manually.
    func observeBukitLocations(onUpdate: @escaping ([Location]) -> Void, onError: @escaping (Error) -> Void) {
        bukitHandle = bukitRef.observe(.value, with: { snapshot in
            guard let value = snapshot.value, snapshot.exists() else {
                onUpdate([]) // No data exists, return an empty array
                return
            }
            
            do {
                // The data is an array of dictionaries, some might be null/invalid
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                // Decode into an array of optionals to handle potential nulls, then remove them
                let bukitData = try JSONDecoder().decode([Location?].self, from: jsonData)
                let validLocations = bukitData.compactMap { $0 }
                onUpdate(validLocations)
            } catch {
                print("Error decoding Bukit locations: \(error)")
                onError(error)
            }
        }, withCancel: onError)
    }
    
    /// Observes "lapangan" locations, decoding the data manually.
    func observeLapanganLocations(onUpdate: @escaping ([Location]) -> Void, onError: @escaping (Error) -> Void) {
        lapanganHandle = lapanganRef.observe(.value, with: { snapshot in
            guard let value = snapshot.value, snapshot.exists() else {
                onUpdate([])
                return
            }
            
            do {
                // The data is an array of valid location dictionaries
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let lapanganData = try JSONDecoder().decode([Location].self, from: jsonData)
                let sortedLocations = lapanganData.sorted { $0.id < $1.id }
                onUpdate(sortedLocations)
            } catch {
                print("Error decoding Lapangan locations: \(error)")
                onError(error)
            }
        }, withCancel: onError)
    }
    
    /// Observes "gedung" locations, decoding the data manually from a dictionary.
    func observeGedungLocations(onUpdate: @escaping ([Location]) -> Void, onError: @escaping (Error) -> Void) {
        gedungHandle = gedungRef.observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any], snapshot.exists() else {
                onUpdate([])
                return
            }
            
            var fetchedLocations: [Location] = []
            // Iterate over dictionary values, not keys
            for locationValue in value.values {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: locationValue, options: [])
                    let location = try JSONDecoder().decode(Location.self, from: jsonData)
                    fetchedLocations.append(location)
                } catch {
                    // Log the error but continue processing other items
                    print("Could not decode a single Gedung location object: \(error)")
                }
            }
            let sortedLocations = fetchedLocations.sorted { $0.id < $1.id }
            onUpdate(sortedLocations)
            
        }, withCancel: onError)
    }

    // MARK: - Cleanup
    
    /// Removes all observers to prevent memory leaks and redundant listeners.
    func removeAllObservers() {
        if let handle = bukitHandle {
            bukitRef.removeObserver(withHandle: handle)
            print("Stopped listening for Bukit locations.")
        }
        if let handle = lapanganHandle {
            lapanganRef.removeObserver(withHandle: handle)
            print("Stopped listening for Lapangan locations.")
        }
        if let handle = gedungHandle {
            gedungRef.removeObserver(withHandle: handle)
            print("Stopped listening for Gedung locations.")
        }
        bukitHandle = nil
        lapanganHandle = nil
        gedungHandle = nil
    }
    
    deinit {
        removeAllObservers()
        print("LocationRepository deinitialized.")
    }
}
