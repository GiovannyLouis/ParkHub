//
//  LocationView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//
import SwiftUI

struct LocationView: View {
    @EnvironmentObject var locationVM: LocationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopAppBar()

                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .center, spacing: 30) {
                            NavigationLink(destination: BukitView()) {
                                RectangleWithImageAndTextView(
                                    imageName: "bukit",
                                    text: "Bukit",
                                    maxWidth: geometry.size.width - 48, // 24 padding each side
                                    height: geometry.size.width > 600 ? 260 : 160
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())

                            NavigationLink(destination: LapanganView()) {
                                RectangleWithImageAndTextView(
                                    imageName: "lapangan",
                                    text: "Lapangan",
                                    maxWidth: geometry.size.width - 48,
                                    height: geometry.size.width > 600 ? 260 : 160
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())

                            NavigationLink(destination: GedungView()) {
                                RectangleWithImageAndTextView(
                                    imageName: "gedung",
                                    text: "Gedung",
                                    maxWidth: geometry.size.width - 48,
                                    height: geometry.size.width > 600 ? 260 : 160
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 24)
//                        .padding(.top, 20)
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .ignoresSafeArea(.keyboard)

                BotAppBar()
            }
        }
    }
}

struct RectangleWithImageAndTextView: View {
    let imageName: String
    let text: String
    let maxWidth: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: maxWidth, height: height)
                .clipped()

            Color.black.opacity(0.4)

            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: maxWidth, height: height)
        .cornerRadius(16)
    }
}

#Preview {
    LocationView()
        .environmentObject(LocationViewModel())
}
