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
    @StateObject var reportViewModel = ReportViewModel()
    @StateObject var locationViewModel = LocationViewModel()
    @StateObject var lessonViewModel = LessonViewModel()
    @StateObject var adminLessonViewModel = AdminLessonViewModel()

    
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
                .environmentObject(reportViewModel)
                .environmentObject(locationViewModel)
                .environmentObject(lessonViewModel)
                .environmentObject(adminLessonViewModel)

        }
    }
}
