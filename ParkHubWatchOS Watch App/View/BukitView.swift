//
//  BukitView.swift
//  ParkHubWatchOS Watch App
//
//  Created by student on 10/06/25.
//

import SwiftUI

struct BukitView: View {
    @EnvironmentObject var viewModel: LocationViewModel

    var body: some View {
        ScrollView {
            if viewModel.bukitLocations.isEmpty {
                ProgressView()
            } else {
                VStack(spacing: 16) {
                    // Top Arrow Bar
                    ImageBar(systemName: "chevron.backward.2")

                    // VertiBukit section (Horizontal scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.vertiBukitLocations.reversed()) { location in
                                VertiBukitView(location: location, color: viewModel.getColor(for: location))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // "Bukit" Text Box
                    ZStack {
                        Text("Bukit")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80) // Reduced height
                    .background(Color(red: 0.298, green: 0.392, blue: 0.266))
                    .cornerRadius(12)


                    // HorizBukit section
                    VStack {
                        ForEach(viewModel.horizBukitLocations) { location in
                            HorizBukitView(location: location, color: viewModel.getColor(for: location))
                        }
                    }

                    // Side Arrow Bar (now horizontal)
                    ImageBar(systemName: "chevron.down.2")
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Bukit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper for the gray bars
private struct ImageBar: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.caption.weight(.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(8)
    }
}


struct VertiBukitView: View {
    let location: Location
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 12, height: 24)
            .overlay(
                Text(location.nama)
                    .font(.system(size: 6))
                    .foregroundColor(.black)
            )
            .padding(.horizontal, 2)
    }
}

struct HorizBukitView: View {
    let location: Location
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 24, height: 12)
             .overlay(
                Text(location.nama)
                    .font(.system(size: 4))
                    .foregroundColor(.black)
            )
            .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        BukitView()
            .environmentObject(LocationViewModel(repository: LocationRepository()))
    }
}
