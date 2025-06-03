//
//  BukitView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct BukitView: View {
    @StateObject private var viewModel = BukitViewModel()
    // In a real app, this viewModel might be passed in or be an @EnvironmentObject

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            // Content Area
            // The .layoutPriority(1) helps this ZStack take available vertical space
            // similar to .weight(1f) in Compose Column
            ZStack {
                Color.white // Background for the content area
                
                if viewModel.locations.isEmpty {
                    // Corresponds to initial loading or if data fetch fails to populate
                    ProgressView() // SwiftUI's equivalent to CircularProgressIndicator
                } else {
                    ScrollView { // Added ScrollView in case content overflows on smaller screens
                        VStack(alignment: .center, spacing: 0) { // Main content column
                            Spacer() // Spacer(Modifier.height(8.dp))

                            // Top arrow bar
                            ZStack {
                                Image(systemName: "chevron.backward.2") // R.drawable.baseline_keyboard_double_arrow_left_24
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjust size as needed
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .background(Color.gray.opacity(0.5)) // Color.Gray

                            // Main horizontal section (side arrow + parking spots)
                            HStack(alignment: .top, spacing: 0) {
                                // Side arrow bar
                                ZStack {
                                    Image(systemName: "chevron.down.2") // R.drawable.baseline_keyboard_double_arrow_down_24
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20) // Adjust size
                                }
                                .frame(width: 24, height: 440) // size(24.dp, 440.dp)
                                .background(Color.gray.opacity(0.5)) // Color.Gray

                                // Parking spots and "Bukit" text area
                                VStack(alignment: .leading, spacing: 0) {
                                    Spacer().frame(height: 8) // Spacer(Modifier.height(8.dp))

                                    // Row for VertiBukit (arranged from right to left in compose)
                                    // Using (0..<18).reversed() to match '17 downTo 0'
                                    // And `Spacer()` at the beginning to push content to the right
                                    HStack(spacing: 0) {
                                        Spacer() // Pushes VertiBukitViews to the right
                                        ForEach(viewModel.vertiBukitLocations.reversed()) { location in
                                            VertiBukitView(location: location, color: viewModel.getColor(for: location))
                                        }
                                    }
                                    .frame(maxWidth: .infinity) // fillMaxWidth

                                    Spacer().frame(height: 8)

                                    // Row for HorizBukit and "Bukit" text box
                                    HStack(alignment: .top, spacing: 0) {
                                        VStack(alignment: .leading, spacing: 0) {
                                            // Column(Modifier.padding(8.dp)) - padding applied to this VStack
                                            ForEach(viewModel.horizBukitLocations) { location in
                                                HorizBukitView(location: location, color: viewModel.getColor(for: location))
                                            }
                                        }
                                        .padding(8) // Padding for the HorizBukit column

                                        // "Bukit" Text Box
                                        ZStack {
                                            Text("Bukit")
                                                .foregroundColor(.white)
                                                .font(.system(size: 40, weight: .bold))
                                        }
                                        .frame(maxWidth: .infinity) // fillMaxWidth relative to its parent HStack space
                                        .frame(height: 400) // height(400.dp)
                                        .background(Color(red: 0.298, green: 0.392, blue: 0.266)) // Color(0xff4c6444)
                                    }
                                }
                            }
                        }
                        .padding(16) // .padding(16.dp) on the outer Column in Compose
                    }
                }
            }
            .layoutPriority(1) // Crucial for taking up space

            BotAppBar()
        }
        .edgesIgnoringSafeArea(.bottom) // If BotAppBar is meant to be at the very bottom
        // .onAppear {
        //     viewModel.loadBukitLocations() // Data is loaded in init, but could be triggered here too
        // }
    }
}

struct VertiBukitView: View {
    let location: Location
    let color: Color // Pass color directly to simplify

    var body: some View {
        // The original Compose VertiBukit has spacers on either side of the box.
        // The HStack here with spacing:0 ensures these views are tightly packed
        // if used in a loop.
        HStack(spacing: 0) {
            Spacer().frame(width: 2)
            ZStack{
                Rectangle()
                    .fill(color)
                    .frame(width: 12, height: 24)
                Text(location.nama)
                    .font(.system(size: 6))// Original was commented out
            }
            .frame(width: 12, height: 24)
            Spacer().frame(width: 2)
        }
    }
}

struct HorizBukitView: View {
    let location: Location
    let color: Color // Pass color directly

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 2)
            ZStack{
                Rectangle()
                    .fill(color)
                    .frame(width: 24, height: 12)
                Text(location.nama)
                    .font(.system(size: 4))// Original was commented out
            }
            .frame(width: 24, height: 12)
            Spacer().frame(height: 2)
        }
    }
}

#Preview {
    BukitView()
}
