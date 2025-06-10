//
//  ContentView.swift
//  ParkHubWatchOS Watch App
//
//  Created by student on 10/06/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationVM: LocationViewModel
    var body: some View {
        // NavigationStack is the root for watchOS navigation
        NavigationStack {
            // A List is often more idiomatic for watchOS menus than a ScrollView
            List {
                NavigationLink(destination: BukitView()) {
                    RectangleWithImageAndTextView(
                        imageName: "bukit",
                        text: "Bukit"
                    )
                }
                .listRowInsets(EdgeInsets()) // Make the view fill the row

                NavigationLink(destination: LapanganView()) {
                    RectangleWithImageAndTextView(
                        imageName: "lapangan",
                        text: "Lapangan"
                    )
                }
                .listRowInsets(EdgeInsets())

                NavigationLink(destination: GedungView()) {
                    RectangleWithImageAndTextView(
                        imageName: "gedung",
                        text: "Gedung"
                    )
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.carousel) // A nice full-screen swipeable style for watchOS
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            // This will run when the view first appears
            await locationVM.loadAllLocations()
        }
    }
}

struct RectangleWithImageAndTextView: View {
    let imageName: String
    let text: String

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.4))

            Text(text)
                .font(.title3) // Adjusted font size for watchOS
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 204, height: 120) // Reduced height for watch screen
        .cornerRadius(16)
    }
}

#Preview {
    // Pass a dummy view model for the preview to work
    ContentView()
        .environmentObject(LocationViewModel(repository: LocationRepository()))
}
