//
//  LocationView.swift
//  ParkHub
//
//  Created by student on 30/05/25.
//

import SwiftUI

// --- Main Location Page View ---

struct LocationView: View {
    // In a real app with NavigationStack, you might not need to pass a controller
    // explicitly if NavigationLinks are self-contained.
    // For this translation, we'll embed it in a NavigationStack.

    var body: some View {
        NavigationStack { // Manages navigation state
            VStack() { // Equivalent to the outer Column
                TopAppBar()

                ScrollView { // To allow content to scroll if it exceeds screen height
                    VStack(alignment: .center, spacing: 30) {
                        NavigationLink(destination: BukitView()) {
                            RectangleWithImageAndTextView(
                                imageName: "bukit", // Assumes "bukit.jpg" or "bukit.png" is in Assets
                                text: "Bukit"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        NavigationLink(destination: LapanganView()) {
                            RectangleWithImageAndTextView(
                                imageName: "lapangan",
                                text: "Lapangan"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        NavigationLink(destination: GedungView()) {
                            RectangleWithImageAndTextView(
                                imageName: "gedung",
                                text: "Gedung"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 30)
                }
                // The ScrollView will take up the available space, similar to weight(1f)

                Spacer() // Pushes the BotAppBarView to the bottom

                BotAppBar()
            }
            .ignoresSafeArea(.keyboard) // Good practice
            // .navigationTitle("Locations") // Alternative way to set title if TopAppBarView doesn't
            // .navigationBarHidden(true) // If TopAppBarView fully replaces the system nav bar
        }
    }
}

struct RectangleWithImageAndTextView: View {
    let imageName: String
    let text: String

    var body: some View {
        // NavigationLink handles the click and navigation
        ZStack {
            // Background Image
            Image(imageName) // Ensure this image exists in your Assets.xcassets
                .resizable()
                .aspectRatio(contentMode: .fill) // Equivalent to ContentScale.Crop
                .frame(height: 160) // Set height before clipping if aspect ratio is fill
                .clipped() // Important for .fill to not overflow rounded corners before masking

            // Overlay
            Color.black.opacity(0.4)

            // Overlay Text
            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                // .padding(.top, 8) // This padding might make it not perfectly centered.
                                  // If you want it truly centered, remove this.
                                  // If it's an intentional offset, keep it.
        }
        .frame(maxWidth: .infinity) // Equivalent to fillMaxWidth
        .frame(height: 160)
        .cornerRadius(16)
        // .background(Color.gray.opacity(0.2)) // Fallback if image fails to load, not in original
    }
}

// --- Preview ---

#Preview {
    LocationView()
}
