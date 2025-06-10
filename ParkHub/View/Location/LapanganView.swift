//
//  LapanganView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//
import SwiftUI

struct LapanganView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var viewModel: LocationViewModel

    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    private var scale: CGFloat {
        isIPad ? 1.8 : 1.0
    }

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ZStack {
                Color.white

                if viewModel.lapanganLocations.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(alignment: .center, spacing: 0) {
                            HStack(spacing: 0) {
                                Spacer().frame(width: 36 * scale)
                                ForEach(viewModel.locations_260_273) { location in
                                    VertiLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                }
                                ArrowBoxView(systemImageName: "chevron.up.2", scale: scale)
                                    .padding(.horizontal, 4 * scale)
                                ArrowBoxView(systemImageName: "chevron.down.2", scale: scale)
                            }

                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right.2").resizable().scaledToFit().frame(width: 18 * scale, height: 18 * scale)
                                Spacer()
                                Image(systemName: "chevron.right.2").resizable().scaledToFit().frame(width: 18 * scale, height: 18 * scale)
                                Spacer()
                            }
                            .frame(width: 264 * scale, height: 24 * scale)
                            .background(Color.gray.opacity(0.5))

                            HStack(alignment: .top, spacing: 0) {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_220_259_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                    }
                                }
                                Spacer().frame(width: 8 * scale)
                                ArrowShaftView(systemImageName: "chevron.up.2", height: 492 * scale, scale: scale)
                                Spacer().frame(width: 8 * scale)

                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_180_219_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                    }
                                }
                                Spacer().frame(width: 8 * scale)
                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_140_179_rev) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                    }
                                }
                                Spacer().frame(width: 8 * scale)
                                ArrowShaftView(systemImageName: "chevron.up.2", height: 492 * scale, scale: scale)
                                Spacer().frame(width: 8 * scale)

                                VStack(alignment: .center, spacing: 0) {
                                    Spacer().frame(height: 4 * scale)
                                    HStack(spacing: 0) {
                                        ForEach(viewModel.locations_274_280) { location in
                                            VertiLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                        }
                                    }
                                    .frame(width: 120 * scale)

                                    Spacer().frame(height: 4 * scale)
                                    ZStack {
                                        Text("Lapangan basket")
                                            .font(.system(size: 14 * scale))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding(4 * scale)
                                    }
                                    .frame(width: 120 * scale, height: 152 * scale)
                                    .background(Color(red: 0.298, green: 0.392, blue: 0.266))
                                    
                                    Spacer().frame(height: 4 * scale)

                                    HStack(alignment: .top, spacing: 0) {
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_115_139_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                            }
                                        }
                                        Spacer().frame(width: 8 * scale)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_90_114_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                            }
                                        }
                                        Spacer().frame(width: 8 * scale)
                                        ArrowShaftView(systemImageName: "chevron.up.2", height: 312 * scale, scale: scale)
                                        Spacer().frame(width: 8 * scale)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_65_89_rev) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                            }
                                        }
                                        Spacer().frame(width: 8 * scale)
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.locations_40_64) { location in
                                                HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                            }
                                        }
                                    }
                                }
                                Spacer().frame(width: 8 * scale)
                                ArrowShaftView(systemImageName: "chevron.down.2", height: 492 * scale, scale: scale)
                                Spacer().frame(width: 8 * scale)

                                VStack(spacing: 0) {
                                    ForEach(viewModel.locations_0_39) { location in
                                        HorizLapanganView(color: viewModel.getColor(for: location), scale: scale)
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.left.2").resizable().scaledToFit().frame(width: 18 * scale, height: 18 * scale)
                                Spacer()
                                Image(systemName: "chevron.left.2").resizable().scaledToFit().frame(width: 18 * scale, height: 18 * scale)
                                Spacer()
                            }
                            .frame(width: 264 * scale, height: 24 * scale)
                            .background(Color.gray.opacity(0.5))
                        }
                        .padding(8 * scale)
                    }
                }
            }
            .layoutPriority(1)

            BotAppBar()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ArrowBoxView: View {
    let systemImageName: String
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 18 * scale, height: 18 * scale)
        }
        .frame(width: 24 * scale, height: 24 * scale)
        .background(Color.gray.opacity(0.5))
    }
}

struct ArrowShaftView: View {
    let systemImageName: String
    let height: CGFloat
    let scale: CGFloat

    var body: some View {
        ZStack {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 18 * scale, height: 18 * scale)
        }
        .frame(width: 24 * scale, height: height)
        .background(Color.gray.opacity(0.5))
    }
}

struct VertiLapanganView: View {
    let color: Color
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 2 * scale)
            Rectangle()
                .fill(color)
                .frame(width: 8 * scale, height: 16 * scale)
            Spacer().frame(width: 2 * scale)
        }
    }
}

struct HorizLapanganView: View {
    let color: Color
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 4 * scale)
            Rectangle()
                .fill(color)
                .frame(width: 16 * scale, height: 8 * scale)
        }
    }
}


#Preview() {
    LapanganView()
        .environmentObject(LocationViewModel())
}

