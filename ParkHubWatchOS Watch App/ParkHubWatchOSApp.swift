//
//  ParkHubWatchOSApp.swift
//  ParkHubWatchOS Watch App
//
//  Created by student on 10/06/25.
//

import SwiftUI
import WatchKit // Required for the App Delegate
import FirebaseCore
import FirebaseAppCheck

// --- 1. Use an App Delegate for reliable Firebase configuration ---
// This is the standard best practice for watchOS.
class AppDelegate: NSObject, WKApplicationDelegate {
  func applicationDidFinishLaunching() {
    FirebaseApp.configure()
    print("Firebase configured for watchOS.")
    
    #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("Firebase AppCheck configured for DEBUG on watchOS.")
    #endif
  }
}

@main
struct ParkHubWatchOS_Watch_AppApp: App {
    // Register the App Delegate to run the configuration code
    @WKApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // --- 2. Explicitly create the ViewModel with the desired repository ---
    
    // OPTION A: For live data from Firebase (use for the final app)
    @StateObject private var locationViewModel = LocationViewModel(repository: LocationRepository())
    
    // OPTION B: For development with fast, offline mock data (HIGHLY RECOMMENDED for building UI)
    // To use this, comment out Option A and uncomment this line:
    // @StateObject private var locationViewModel = LocationViewModel(repository: MockLocationRepository())
    
    var body: some Scene {
        WindowGroup {
            // --- 3. Set your LocationView as the starting point ---
            ContentView()
                .environmentObject(locationViewModel) // Inject the ViewModel
        }
    }
}
