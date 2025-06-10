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
                ScrollView {
                    // VertiBukit section (Horizontal scroll)
                    HStack {
                        ForEach(viewModel.vertiBukitLocations.reversed()) { location in
                            VertiBukitView(location: location, color: viewModel.getColor(for: location))
                        }
                    }
                    .padding(.horizontal)

                    HStack {
                        VStack {
                            ForEach(viewModel.horizBukitLocations) { location in
                                HorizBukitView(location: location, color: viewModel.getColor(for: location))
                            }
                        }
                        ZStack {
                            Text("Bukit")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200) // Reduced height
                        .background(Color(red: 0.298, green: 0.392, blue: 0.266))
                        .cornerRadius(4)

                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Bukit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VertiBukitView: View {
    let location: Location
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 4, height: 8)
//            .overlay(
//                Text(location.nama)
//                    .font(.system(size: 3))
//                    .foregroundColor(.black)
//            )
            .padding(.leading, 1)
    }
}

struct HorizBukitView: View {
    let location: Location
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 4)
//            .overlay(
//                Text(location.nama)
//                    .font(.system(size: 4))
//                    .foregroundColor(.black)
//            )
            .padding(.top, 1)
    }
}

#Preview {
    NavigationStack {
        BukitView()
            .environmentObject(LocationViewModel(repository: LocationRepository()))
    }
}
