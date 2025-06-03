//
//  GedungView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct GedungView: View {
    @EnvironmentObject var viewModel: GedungViewModel

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar() // Replace with your actual TopAppBar

            ZStack { // Main Content Box
                Color.white // Background

                if viewModel.locations.isEmpty {
                    ProgressView()
                } else {
                    // Floor Display and Navigation Row
                    // Original Row had .fillMaxSize().padding(16.dp), horizontalArrangement = Center, verticalAlignment = CenterVertically
                    // We'll use a GeometryReader to help with vertical centering if needed, or rely on Spacer for simpler cases.
                    // For now, let's use Spacers within the HStack for centering.
                    HStack(alignment: .center, spacing: 0) { // Main Row for Left, Center, Right
                        // --- Left Section ---
                        VStack(alignment: .trailing) { // Alignment matches Compose
                            if viewModel.isCurrentFloorEven { // Even Floor Left
                                ZStack {
                                    Image(systemName: "chevron.right.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black) // Ensure icon is visible on gray background
                                }
                                .frame(width: 64, height: 40)
                                .background(Color.gray.opacity(0.5))
                                ForEach(viewModel.evenFloorLeftSectionSpots) { location in
                                    HorizGedungView(color: viewModel.getGedungColor(isFilled: location.isFilled))
                                }
                                ZStack {
                                    Image(systemName: "chevron.left.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black) // Ensure icon is visible on gray background
                                }
                                .frame(width: 64, height: 40)
                                .background(Color.gray.opacity(0.5))
                            } else { // Odd Floor Left
                                VStack(alignment: .trailing, spacing: 0) { // Explicit VStack for alignment
                                    ForEach(viewModel.oddFloorLeftSectionSpots) { location in
                                        HorizGedungView(color: viewModel.getGedungColor(isFilled: location.isFilled))
                                    }
                                }
                            }
                        }
                        .frame(width: 64)
                        // The alignment of the VStack itself within the HStack will be .center by default.
                        // If specific alignment like .top or .bottom is needed for the whole column, adjust the HStack's alignment.

                        // --- Center Section (Floor Selector) ---
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill") // baseline_arrow_drop_up_24
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80) // Adjusted from 128dp for better proportion with text
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    viewModel.incrementFloor()
                                }

                            Text("P\(viewModel.currentFloor)")
                                .font(.system(size: 48)) // Adjusted from 80sp
                                .fontWeight(.medium) // .W500
                                .frame(width: 100)

                            Image(systemName: "arrowtriangle.down.fill") // baseline_arrow_drop_down_24
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80) // Adjusted
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .onTapGesture {
                                    viewModel.decrementFloor()
                                }
                        }
                        .padding(.horizontal, 64) // Adjusted from 48dp

                        // --- Right Section ---
                        VStack(alignment: .leading) { // Default leading alignment for VStacks
                            if viewModel.isCurrentFloorEven { // Even Floor Right
                                ForEach(viewModel.evenFloorRightSectionSpotsTop) { location in
                                    HorizGedungView(color: viewModel.getGedungColor(isFilled: location.isFilled))
                                }
                                ZStack { // Station Icon Box
                                    Image(systemName: "figure.walk.motion") // baseline_transfer_within_a_station_24
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.black) // Ensure icon is visible
                                }
                                .frame(width: 40, height: 84)
                                .background(Color.cyan) // Color.Cyan

                                ForEach(viewModel.evenFloorRightSectionSpotsBottom) { location in
                                    HorizGedungView(color: viewModel.getGedungColor(isFilled: location.isFilled))
                                }
                            } else { // Odd Floor Right
                                ZStack {
                                    Image(systemName: "chevron.right.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black) // Ensure icon is visible on gray background
                                }
                                .frame(width: 64, height: 40)
                                .background(Color.gray.opacity(0.5))
                                ForEach(viewModel.oddFloorRightSectionSpots) { location in
                                    HorizGedungView(color: viewModel.getGedungColor(isFilled: location.isFilled))
                                }
                                ZStack {
                                    Image(systemName: "chevron.left.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black) // Ensure icon is visible on gray background
                                }
                                .frame(width: 64, height: 40)
                                .background(Color.gray.opacity(0.5))
                            }
                        }
                        .frame(width: 64)
                    }
                    .padding(16) // Corresponds to .padding(16.dp) on the main Row in Compose
                    // The .fillMaxSize() on the Row and verticalAlignment = CenterVertically
                    // means the HStack should try to center itself vertically.
                    // If the content is shorter than the screen, outer Spacers or GeometryReader might be needed.
                    // For now, this structure should work well if content naturally fills or is centered by the HStack's parent ZStack.
                }
            }
            .layoutPriority(1) // To take available vertical space

            BotAppBar() // Replace with your actual BotAppBar
        }
        .edgesIgnoringSafeArea(.bottom) // If BotAppBar is meant to be at the very bottom
    }
}

struct HorizGedungView: View {
    let color: Color
    // let name: String // Original Compose had 'num' but didn't display it

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 4)
            Rectangle()
                .fill(color)
                .frame(width: 40, height: 20)
            // Text(name, font: .system(size: 4)) // If you want to display it
            Spacer().frame(height: 4)
        }
    }
}

#Preview {
    GedungView()
        .environmentObject(GedungViewModel())
}
