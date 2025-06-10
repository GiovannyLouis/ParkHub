//
//  GedungView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct GedungView: View {
    @EnvironmentObject var viewModel: LocationViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack { // Main Content Box
                if viewModel.gedungLocations.isEmpty {
                    ProgressView()
                } else {
                    // Floor Display and Navigation Row
                    // Original Row had .fillMaxSize().padding(16.dp), horizontalArrangement = Center, verticalAlignment = CenterVertically
                    // We'll use a GeometryReader to help with vertical centering if needed, or rely on Spacer for simpler cases.
                    // For now, let's use Spacers within the HStack for centering.
                    ScrollView {
                        HStack(alignment: .center, spacing: 0) { // Main Row for Left, Center, Right
                            // --- Left Section ---
                            VStack(alignment: .trailing) { // Alignment matches Compose
                                if viewModel.isCurrentGedungFloorEven { // Even Floor Left
                                    ZStack {
                                        Image(systemName: "chevron.right.2")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.black) // Ensure icon is visible on gray background
                                    }
                                    .frame(width: 16, height: 10)
                                    .background(Color.gray.opacity(0.5))
                                    ForEach(viewModel.evenFloorLeftSectionSpots) { location in
                                        HorizGedungView(color: viewModel.getColor(for: location))
                                    }
                                    ZStack {
                                        Image(systemName: "chevron.left.2")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.black) // Ensure icon is visible on gray background
                                    }
                                    .frame(width: 16, height: 10)
                                    .background(Color.gray.opacity(0.5))
                                } else { // Odd Floor Left
                                    VStack(alignment: .trailing, spacing: 0) { // Explicit VStack for alignment
                                        ForEach(viewModel.oddFloorLeftSectionSpots) { location in
                                            HorizGedungView(color: viewModel.getColor(for: location))
                                        }
                                    }
                                }
                            }
                            .frame(width: 32)
                            // The alignment of the VStack itself within the HStack will be .center by default.
                            // If specific alignment like .top or .bottom is needed for the whole column, adjust the HStack's alignment.

                            // --- Center Section (Floor Selector) ---
                            VStack(spacing: 0) {
                                Image(systemName: "arrowtriangle.up.fill") // baseline_arrow_drop_up_24
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjusted from 128dp for better proportion with text
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 4)
                                    .onTapGesture {
                                        viewModel.incrementGedungFloor()
                                    }

                                Text("P\(viewModel.currentGedungFloor)")
                                    .font(.system(size: 12)) // Adjusted from 80sp
                                    .fontWeight(.medium) // .W500
                                    .frame(width: 32)

                                Image(systemName: "arrowtriangle.down.fill") // baseline_arrow_drop_down_24
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjusted
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                                    .onTapGesture {
                                        viewModel.decrementGedungFloor()
                                    }
                            }
                            .padding(.horizontal, 64) // Adjusted from 48dp

                            // --- Right Section ---
                            VStack(alignment: .leading) { // Default leading alignment for VStacks
                                if viewModel.isCurrentGedungFloorEven { // Even Floor Right
                                    ForEach(viewModel.evenFloorRightSectionSpotsTop) { location in
                                        HorizGedungView(color: viewModel.getColor(for: location))
                                    }
                                    ZStack { // Station Icon Box
                                        Image(systemName: "figure.walk.motion") // baseline_transfer_within_a_station_24
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.black) // Ensure icon is visible
                                    }
                                    .frame(width: 20, height: 20)
                                    .background(Color.cyan) // Color.Cyan

                                    ForEach(viewModel.evenFloorRightSectionSpotsBottom) { location in
                                        HorizGedungView(color: viewModel.getColor(for: location))
                                    }
                                } else { // Odd Floor Right
                                    ZStack {
                                        Image(systemName: "chevron.right.2")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.black) // Ensure icon is visible on gray background
                                    }
                                    .frame(width: 16, height: 10)
                                    .background(Color.gray.opacity(0.5))
                                    ForEach(viewModel.oddFloorRightSectionSpots) { location in
                                        HorizGedungView(color: viewModel.getColor(for: location))
                                    }
                                    ZStack {
                                        Image(systemName: "chevron.left.2")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.black) // Ensure icon is visible on gray background
                                    }
                                    .frame(width: 16, height: 10)
                                    .background(Color.gray.opacity(0.5))
                                }
                            }
                            .frame(width: 32)
                        }
                        .padding(8)
                    }
                    // The .fillMaxSize() on the Row and verticalAlignment = CenterVertically
                    // means the HStack should try to center itself vertically.
                    // If the content is shorter than the screen, outer Spacers or GeometryReader might be needed.
                    // For now, this structure should work well if content naturally fills or is centered by the HStack's parent ZStack.
                }
            }
            .layoutPriority(1) // To take available vertical space
        }
        .edgesIgnoringSafeArea(.bottom) // If BotAppBar is meant to be at the very bottom
    }
}

struct HorizGedungView: View {
    let color: Color
    // let name: String // Original Compose had 'num' but didn't display it

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 1)
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 6)
            // Text(name, font: .system(size: 4)) // If you want to display it
            Spacer().frame(height: 1)
        }
    }
}

#Preview {
    GedungView()
        .environmentObject(LocationViewModel(repository: LocationRepository()))
}
