// MainPageView.swift
// ParkHub
// Created by student on 03/06/25.

import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showAuthSheet = false
    @State private var isRegistering = false // To control if the sheet shows Login or Register

    var body: some View {
        // Using NavigationView here allows for a title bar and potentially other navigation
        // if MainPageView becomes more complex later.
        NavigationView {
            VStack {
                if authVM.isSignedIn {
                    // Content to show when the user IS signed in
                    Text("Welcome to the Main Page!")
                        .font(.largeTitle)
                        .padding()

                    if let user = authVM.firebaseAuthUser {
                        Text("Hello, \(user.displayName ?? user.email ?? "User")!")
                            .font(.title2)
                            .padding(.bottom)
                    }
                    
                    Spacer()

                    Button("Log Out") {
                        authVM.signOut()
                        // Input fields are typically cleared by AuthViewModel or when sheet appears
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    // Content to show when the user IS NOT signed in
                    // This part might be brief if the sheet appears immediately.
                    Spacer()
                    LogoBig() // Assuming LogoBig is defined and accessible
                        .padding(.bottom, 30)
                    Text("Please log in or register.")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("ParkHub Main") // Example title
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // When MainPageView appears, check if the user is signed in.
                // If not, immediately prepare to present the authentication sheet.
                if !authVM.isSignedIn {
                    isRegistering = false // Default to login when sheet appears
                    // Delay slightly to allow the view to appear before presenting sheet
                    // This can sometimes help with smoother UI transitions.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAuthSheet = true
                    }
                }
            }
            .sheet(isPresented: $showAuthSheet, onDismiss: {
                // This block is called when the sheet is dismissed by any means
                // (swipe, programmatic dismiss, etc.)
                // If the user dismissed the sheet without logging in,
                // and they are still not signed in, we might want to re-trigger the sheet
                // or ensure the UI reflects the "not logged in" state.
                if !authVM.isSignedIn {
                    print("Auth sheet dismissed, user still not signed in.")
                    // If login is mandatory, you might want to re-show the sheet:
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Add delay
                    //    showAuthSheet = true
                    // }
                }
            }) {
                // Content of the sheet: The AuthSheetContainerView
                AuthSheetContainerView(isRegisteringInitially: $isRegistering)
                    .environmentObject(authVM)
            }
            // This ensures that if the auth state changes (e.g., user signs out elsewhere,
            // or token expires and listener updates), the sheet presentation is re-evaluated.
            .onChange(of: authVM.isSignedIn) { newIsSignedInStatus in
                if !newIsSignedInStatus && !showAuthSheet {
                    // If user becomes signed out while on this page, and sheet isn't already up,
                    // show the auth sheet.
                    isRegistering = false
                    // Add a slight delay if needed for UI updates
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAuthSheet = true
                    }
                } else if newIsSignedInStatus && showAuthSheet {
                    // If user becomes signed in (e.g. auto-login, deep link)
                    // and the sheet is somehow still up, ensure it's dismissed.
                    // (AuthSheetContainerView should also handle this, but this is a fallback)
                    showAuthSheet = false
                }
            }
        }
    }
}

// AuthSheetContainerView (ensure this is in your project and accessible)
// This view manages showing LoginView or RegisterView within the sheet
// and handles dismissing the sheet on successful authentication.
// (This is the same as provided in previous answers)
struct AuthSheetContainerView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var isRegisteringInitially: Bool
    @State private var currentIsRegistering: Bool

    @Environment(\.dismiss) var dismissSheet

    init(isRegisteringInitially: Binding<Bool>) {
        _isRegisteringInitially = isRegisteringInitially
        _currentIsRegistering = State(initialValue: isRegisteringInitially.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if currentIsRegistering {
                    RegisterView(showRegisterSheet: $currentIsRegistering)
                } else {
                    LoginView(showRegisterSheet: $currentIsRegistering)
                }
            }
            .navigationTitle(currentIsRegistering ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            currentIsRegistering = isRegisteringInitially
            authVM.clearInputFields() // Clear fields for a fresh form
            authVM.clearAuthError()   // Clear any previous errors
        }
        .onChange(of: authVM.isSignedIn) { newIsSignedInState in
            if newIsSignedInState {
                dismissSheet() // Dismiss the sheet upon successful sign-in/sign-up
            }
        }
        .interactiveDismissDisabled(authVM.isLoading) // Prevent swipe-dismiss during auth operation
    }
}

// Dummy LogoBig for preview and compilation if not defined elsewhere
// struct LogoBig: View {
//     var body: some View {
//         Image(systemName: "p.square.fill") // Placeholder
//             .resizable()
//             .scaledToFit()
//             .frame(width: 100, height: 100)
//             .foregroundColor(Color(red: 1.0, green: 0.89, blue: 0.78))
//             .padding()
//             .background(Circle().fill(Color.white.opacity(0.3)))
//     }
// }

#Preview {
    MainPageView()
        .environmentObject(AuthViewModel()) // Provide a dummy AuthViewModel for preview
}
