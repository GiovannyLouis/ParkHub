import SwiftUI

struct GedungView: View {
    @EnvironmentObject var viewModel: LocationViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ZStack {
                Color.white

                if viewModel.gedungLocations.isEmpty {
                    ProgressView()
                } else {
                    HStack(alignment: .center, spacing: 0) {
                        VStack(alignment: .trailing) {
                            if viewModel.isCurrentGedungFloorEven {
                                ZStack {
                                    Image(systemName: "chevron.right.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isIpad ? 36 : 24, height: isIpad ? 36 : 24)
                                        .foregroundColor(.black)
                                }
                                .frame(width: isIpad ? 96 : 64, height: isIpad ? 60 : 40)
                                .background(Color.gray.opacity(0.5))
                                ForEach(viewModel.evenFloorLeftSectionSpots) { location in
                                    HorizGedungView(color: viewModel.getColor(for: location), isIpad: isIpad)
                                }
                                ZStack {
                                    Image(systemName: "chevron.left.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isIpad ? 36 : 24, height: isIpad ? 36 : 24)
                                        .foregroundColor(.black)
                                }
                                .frame(width: isIpad ? 96 : 64, height: isIpad ? 60 : 40)
                                .background(Color.gray.opacity(0.5))
                            } else {
                                VStack(alignment: .trailing, spacing: 0) {
                                    ForEach(viewModel.oddFloorLeftSectionSpots) { location in
                                        HorizGedungView(color: viewModel.getColor(for: location), isIpad: isIpad)
                                    }
                                }
                            }
                        }
                        .frame(width: isIpad ? 96 : 64)

                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIpad ? 120 : 80, height: isIpad ? 120 : 80)
                                .foregroundColor(.gray)
                                .padding(.bottom, isIpad ? 15 : 10)
                                .onTapGesture {
                                    viewModel.incrementGedungFloor()
                                }

                            Text("P\(viewModel.currentGedungFloor)")
                                .font(.system(size: isIpad ? 72 : 48))
                                .fontWeight(.medium)
                                .frame(width: isIpad ? 150 : 100)

                            Image(systemName: "arrowtriangle.down.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isIpad ? 120 : 80, height: isIpad ? 120 : 80)
                                .foregroundColor(.gray)
                                .padding(.top, isIpad ? 15 : 10)
                                .onTapGesture {
                                    viewModel.decrementGedungFloor()
                                }
                        }
                        .padding(.horizontal, isIpad ? 96 : 64)

                        VStack(alignment: .leading) {
                            if viewModel.isCurrentGedungFloorEven {
                                ForEach(viewModel.evenFloorRightSectionSpotsTop) { location in
                                    HorizGedungView(color: viewModel.getColor(for: location), isIpad: isIpad)
                                }
                                ZStack {
                                    Image(systemName: "figure.walk.motion")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isIpad ? 48 : 32, height: isIpad ? 48 : 32)
                                        .foregroundColor(.black)
                                }
                                .frame(width: isIpad ? 60 : 40, height: isIpad ? 126 : 84)
                                .background(Color.cyan)

                                ForEach(viewModel.evenFloorRightSectionSpotsBottom) { location in
                                    HorizGedungView(color: viewModel.getColor(for: location), isIpad: isIpad)
                                }
                            } else {
                                ZStack {
                                    Image(systemName: "chevron.right.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isIpad ? 36 : 24, height: isIpad ? 36 : 24)
                                        .foregroundColor(.black)
                                }
                                .frame(width: isIpad ? 96 : 64, height: isIpad ? 60 : 40)
                                .background(Color.gray.opacity(0.5))
                                ForEach(viewModel.oddFloorRightSectionSpots) { location in
                                    HorizGedungView(color: viewModel.getColor(for: location), isIpad: isIpad)
                                }
                                ZStack {
                                    Image(systemName: "chevron.left.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: isIpad ? 36 : 24, height: isIpad ? 36 : 24)
                                        .foregroundColor(.black)
                                }
                                .frame(width: isIpad ? 96 : 64, height: isIpad ? 60 : 40)
                                .background(Color.gray.opacity(0.5))
                            }
                        }
                        .frame(width: isIpad ? 96 : 64)
                    }
                    .padding(isIpad ? 24 : 16)
                }
            }
            .layoutPriority(1)

            BotAppBar()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct HorizGedungView: View {
    let color: Color
    let isIpad: Bool

    private var spotWidth: CGFloat { isIpad ? 60 : 40 }
    private var spotHeight: CGFloat { isIpad ? 30 : 20 }
    private var spacerHeight: CGFloat { isIpad ? 6 : 4 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: spacerHeight)
            Rectangle()
                .fill(color)
                .frame(width: spotWidth, height: spotHeight)
            Spacer().frame(height: spacerHeight)
        }
    }
}

#Preview {
    GedungView()
        .environmentObject(LocationViewModel())
}
