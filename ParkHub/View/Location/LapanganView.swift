//
//  LapanganView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct LapanganView: View {
    @EnvironmentObject var viewModel: LapanganViewModel

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar() // Replace with your actual TopAppBar

            ZStack { // Content Area Box
                Color.white // Background

                if viewModel.locations.isEmpty {
                    ProgressView() // Loading state
                } else {
                    // The original Compose Column had .fillMaxSize() and verticalArrangement = Arrangement.Center
                    // For ScrollView, content starts at top. Vertical centering is complex if content is short.
                    // Given the amount of content, ScrollView is appropriate.
                    ScrollView {
                        // This VStack corresponds to the main content Column in Compose
                        // (Modifier.padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally)
                        VStack(alignment: .center, spacing: 0) { // No explicit vertical spacing, rely on children's spacers/padding
                            
                            // Row 1: Spacer, VertiLapangans, 2 Arrow Boxes
                            HStack(spacing: 0) {
                                Spacer().frame(width: 36)
                                ForEach(viewModel.locations_260_273) { location in
                                    VertiLapanganView(color: viewModel.getColor(for: location))
                                }
                                ZStack {
                                    Image(systemName: "chevron.up.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                }
                                .frame(width: 24, height: 24)
                                .background(Color.gray.opacity(0.5))
                                .padding(.horizontal, 4)
                                ZStack {
                                    Image(systemName: "chevron.down.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                }
                                .frame(width: 24, height: 24)
                                .background(Color.gray.opacity(0.5))
                            }

                            // Row 2: Double Arrow Bar
                            // Row(Modifier.background(Color.Gray).size(264.dp, 24.dp), horizontalArrangement = Arrangement.SpaceEvenly)
                            // { Image, Image, Spacer }
                            HStack {
                                Spacer() // For SpaceEvenly effect
                                Image(systemName: "chevron.right.2").resizable().scaledToFit().frame(width: 18, height: 18)
                                Spacer() // For SpaceEvenly effect
                                Image(systemName: "chevron.right.2").resizable().scaledToFit().frame(width: 18, height: 18)
                                Spacer() // For SpaceEvenly effect
                                // The third item (Spacer(Modifier.height(0.dp))) in compose is for spacing calculation.
                                // We achieve similar visual with flexible spacers around two items.
                            }
                            .frame(width: 264, height: 24)
                            .background(Color.gray.opacity(0.5))

                            // Row 3: Main complex layout
                            HStack(alignment: .top, spacing: 0) {
                                // Column 1: HorizLapangans (259 downTo 220)
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_220_259_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location))
                                    }
                                }
                                Spacer().frame(width: 8)
                                ArrowShaftView(systemImageName: "chevron.up.2", height: 492)
                                Spacer().frame(width: 8)

                                // Column 2: HorizLapangans (219 downTo 180)
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_180_219_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location))
                                    }
                                }
                                Spacer().frame(width: 8)
                                // Column 3: HorizLapangans (179 downTo 140)
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_140_179_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location))
                                    }
                                }
                                Spacer().frame(width: 8)
                                ArrowShaftView(systemImageName: "chevron.up.2", height: 492)
                                Spacer().frame(width: 8)

                                // Column 4: Complex Column with BasketBall court etc.
                                VStack(alignment: .center, spacing: 0) {
                                    Spacer().frame(height: 4)
                                    HStack(spacing: 0) { // Centered row of VertiLapangans
                                        ForEach(viewModel.locations_274_280) { location in
                                            VertiLapanganView(color: viewModel.getColor(for: location))
                                        }
                                    }
                                    .frame(width: 120) // As per Modifier.width(120.dp) on parent Row in Compose

                                    Spacer().frame(height: 4)
                                    ZStack { // Lapangan Basket Text Box
                                        Text("Lapangan basket")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center) // Added for better text flow if needed
                                            .padding(4) // Added padding for text
                                    }
                                    .frame(width: 120, height: 152)
                                    .background(Color(red: 0.298, green: 0.392, blue: 0.266))
                                    
                                    Spacer().frame(height: 4)

                                    // Inner Row for more HorizLapangans
                                    HStack(alignment: .top, spacing: 0) {
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_115_139_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location))
                                            }
                                        }
                                        Spacer().frame(width: 8)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_90_114_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location))
                                            }
                                        }
                                        Spacer().frame(width: 8)
                                        ArrowShaftView(systemImageName: "chevron.up.2", height: 312)
                                        Spacer().frame(width: 8)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_65_89_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location))
                                            }
                                        }
                                        Spacer().frame(width: 8)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_40_64) { location in // Not reversed
                                                HorizLapanganView(color: viewModel.getColor(for: location))
                                            }
                                        }
                                    }
                                }
                                Spacer().frame(width: 8)
                                ArrowShaftView(systemImageName: "chevron.down.2", height: 492)
                                Spacer().frame(width: 8)

                                // Column 5: HorizLapangans (0 until 40)
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_0_39) { location in // Not reversed
                                        HorizLapanganView(color: viewModel.getColor(for: location))
                                    }
                                }
                            }
                            HStack {
                                Spacer() // For SpaceEvenly effect
                                Image(systemName: "chevron.left.2").resizable().scaledToFit().frame(width: 18, height: 18)
                                Spacer() // For SpaceEvenly effect
                                Image(systemName: "chevron.left.2").resizable().scaledToFit().frame(width: 18, height: 18)
                                Spacer() // For SpaceEvenly effect
                                // The third item (Spacer(Modifier.height(0.dp))) in compose is for spacing calculation.
                                // We achieve similar visual with flexible spacers around two items.
                            }
                            .frame(width: 264, height: 24)
                            .background(Color.gray.opacity(0.5))
                        }
                        .padding(8) // Corresponds to .padding(8.dp) on the content Column in Compose
                    }
                }
            }
            .layoutPriority(1) // To take available vertical space

            BotAppBar() // Replace with your actual BotAppBar
        }
        .edgesIgnoringSafeArea(.bottom) // If BotAppBar is meant to be at the very bottom
    }
}

// Helper view for the small arrow boxes
struct ArrowBoxView: View {
    let systemImageName: String
    var size: CGFloat = 24
    var imageSize: CGFloat = 18


    var body: some View {
        ZStack {
            Image(systemName: "chevron.up.2")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .frame(width: 24, height: 24)
        .background(Color.gray.opacity(0.5))
    }
}

// Helper view for the long arrow shafts
struct ArrowShaftView: View {
    let systemImageName: String
    var width: CGFloat = 24
    let height: CGFloat
    var imageSize: CGFloat = 18


    var body: some View {
        ZStack {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .frame(width: width, height: height)
        .background(Color.gray.opacity(0.5))
    }
}

struct VertiLapanganView: View {
    let color: Color

    var body: some View {
        // Original: Spacer(2.dp) + Box(8.dp, 16.dp) + Spacer(2.dp)
        // These spacers are within the item, so an outer HStack groups them.
        // The ForEach in parent will handle spacing *between* items if needed.
        HStack(spacing: 0) {
            Spacer().frame(width: 2)
            Rectangle()
                .fill(color)
                .frame(width: 8, height: 16)
            Spacer().frame(width: 2)
        }
    }
}

struct HorizLapanganView: View {
    let color: Color

    var body: some View {
        // Original: Spacer(4.dp) + Box(16.dp, 8.dp)
        // The Spacer is *above* the box.
        VStack(spacing: 0) {
            Spacer().frame(height: 4)
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 8)
        }
    }
}


#Preview {
    LapanganView()
        .environmentObject(LapanganViewModel())
}
