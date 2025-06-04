// TopAppBar.swift
// ParkHub
// Created by student on 30/05/25.

import SwiftUI

// Define primaryOrange and logoutRed if not globally available or in an extension
// For example:
// let primaryOrange = Color(red: 1.0, green: 0.627, blue: 0.004)
// let logoutRed = Color.red // Or your specific hex color for red

struct TopAppBar: View {
    @EnvironmentObject var authVM: AuthViewModel // Add AuthViewModel environment object

    var body: some View {
        HStack { // Main HStack for logo and logout button
            LogoSmall() // Your existing LogoSmall

            Spacer() // Pushes logout button to the trailing edge

            // Logout Button - styled like in LessonDetailView
            Button(action: {
                authVM.signOut() // Call signOut on the AuthViewModel
            }) {
                Text("Logout")
                    .font(.system(size: 16)) // Consistent font size
                    .foregroundColor(.white)
                    .padding(.horizontal, 12) // Consistent padding
                    .padding(.vertical, 8)    // Consistent padding
                    .background(logoutRed)      // Use your defined logoutRed color
                    .cornerRadius(8)          // Consistent corner radius
            }
        }
        .padding(.horizontal) // Add horizontal padding to the HStack content
        .padding(.vertical, 10) // Add some vertical padding (adjust as needed)
        // Apply padding for safe area top inset *before* the background
        // This ensures the background extends into the safe area, but content is inset.
        .frame(maxWidth: .infinity)
        .background(primaryOrange) // Use your defined primaryOrange color

    }
}

// Define LogoSmall if it's not in this file or globally accessible for preview
// struct LogoSmall: View { /* ... your LogoSmall definition ... */ }
// Define color constants if not globally available
// let primaryOrange = Color.orange // Placeholder
// let logoutRed = Color.red       // Placeholder

#Preview {
    TopAppBar()
        .environmentObject(AuthViewModel()) // Provide AuthViewModel for the preview
}
