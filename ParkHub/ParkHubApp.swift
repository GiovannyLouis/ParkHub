//
//  ParkHubApp.swift
//  ParkHub
//
//  Created by student on 21/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ParkHubApp: App {
    @StateObject var authVM = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
        
        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
    }
    var body: some Scene {
        WindowGroup {
            MainPageView()
                .environmentObject(authVM)
        }
    }
}
