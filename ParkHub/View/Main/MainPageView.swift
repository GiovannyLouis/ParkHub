// MainPageView.swift
// ParkHub
// Created by student on 03/06/25.

import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var reportVM: ReportViewModel // For submitting reports

    @EnvironmentObject var bukitVM: BukitViewModel
    @EnvironmentObject var lapanganVM: LapanganViewModel
    @EnvironmentObject var gedungVM: GedungViewModel
    @State private var showAuthSheet = false
    @State private var isRegistering = false

    @State private var showingSubmitReportSheet = false

    var body: some View {
        NavigationView { // Your existing NavigationView
            VStack {
                if authVM.isSignedIn {
                    // Content to show when the user IS signed in
                    Text("Welcome to ParkHub!")
                        .font(.largeTitle)
                        .padding()

                    if let user = authVM.firebaseAuthUser {
                        Text("Hello, \(user.displayName ?? user.email ?? "User")!")
                            .font(.title2)
                            .padding(.bottom)
                    }

                    // Button to create a new report (presents a sheet)
                    Button {
                        reportVM.clearInputFields()
                        showingSubmitReportSheet = true
                    } label: {
                        Label("Create New Report", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    // --- Button to navigate to reportListView ---
                    NavigationLink {
                        // Destination View: reportListView
                        // EnvironmentObjects (authVM, reportVM) will be inherited
                        reportListView()
                            .navigationTitle("All Reports") // Give reportListView a title
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("View All Reports", systemImage: "list.bullet.rectangle.fill")
                            .font(.headline)
                    }
                    .padding()
                    .buttonStyle(.bordered) // Different style for this navigation button
                    .tint(.blue) // Different color
                    // --- End of Button to reportListView ---

                    
                    NavigationLink(destination: LocationView()) {
                        Text("Locations")
                    }
                    
                    Spacer()

                    Button("Log Out") {
                        authVM.signOut()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .tint(.red)

                } else {
                    // Content to show when the user IS NOT signed in
                    Spacer()
                    LogoBig() // Assuming LogoBig is defined and accessible
                        .padding(.bottom, 30)
                    Text("Please log in or register to continue.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("ParkHub") // Title for MainPageView
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !authVM.isSignedIn {
                    isRegistering = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAuthSheet = true
                    }
                }
            }
            .sheet(isPresented: $showAuthSheet, onDismiss: {
                if !authVM.isSignedIn {
                    print("Auth sheet dismissed, user still not signed in.")
                }
            }) {
                AuthSheetContainerView(isRegisteringInitially: $isRegistering)
            }
            .sheet(isPresented: $showingSubmitReportSheet) {
                NavigationView { // Sheet content often has its own NavigationView
                    submitReportView()
                }
            }
            .onChange(of: authVM.isSignedIn) { newIsSignedInStatus in
                if newIsSignedInStatus {
                    if showAuthSheet {
                        showAuthSheet = false
                    }
                } else {
                    if !showAuthSheet {
                        isRegistering = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showAuthSheet = true
                        }
                    }
                }
            }
        }
    }
}

// AuthSheetContainerView (defined in the same file or accessible)
// ... (your AuthSheetContainerView code) ...
// struct AuthSheetContainerView: View { ... }

// Make sure LogoBig, LoginView, RegisterView, submitReportView, reportListView
// are defined and accessible from their respective files.

#Preview {
    // Ensure all necessary dummy views or actual views are available for preview
    // For example, if reportListView uses TopAppBar/BotAppBar, they need to be available.
    // struct reportListView: View { var body: some View { Text("Report List Preview") } } // Dummy for this preview
    // struct submitReportView: View { var body: some View { Text("Submit Report Preview") } } // Dummy
    // struct LogoBig: View { var body: some View { Image(systemName: "p.circle.fill").font(.largeTitle) } } // Dummy
    // struct AuthSheetContainerView: View { ... } // Needs LoginView & RegisterView dummies if not defined

    MainPageView()
        .environmentObject(AuthViewModel())
        .environmentObject(ReportViewModel()) // Make sure ReportViewModel is provided
}
// AuthSheetContainerView is defined here, within the same file.
// This view manages showing LoginView or RegisterView within the sheet
// and handles dismissing the sheet on successful authentication.
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
        NavigationView { // Or NavigationStack for iOS 16+
            Group {
                if currentIsRegistering {
                    // Assuming RegisterView is defined in its own file and accessible
                    RegisterView(showRegisterSheet: $currentIsRegistering)
                } else {
                    // Assuming LoginView is defined in its own file and accessible
                    LoginView(showRegisterSheet: $currentIsRegistering)
                }
            }
            .navigationTitle(currentIsRegistering ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissSheet()
                    }
                }
            }
        }
        .onAppear {
            currentIsRegistering = isRegisteringInitially
            authVM.clearInputFields()
            authVM.clearAuthError()
        }
        .onChange(of: authVM.isSignedIn) { newIsSignedInState in
            if newIsSignedInState {
                dismissSheet()
            }
        }
        .interactiveDismissDisabled(authVM.isLoading)
    }
}

#Preview {
    MainPageView()
        .environmentObject(AuthViewModel())
        .environmentObject(ReportViewModel()) // Add ReportViewModel for preview
        .environmentObject(AuthViewModel()) // Provide a dummy AuthViewModel for preview
        .environmentObject(BukitViewModel())
        .environmentObject(LapanganViewModel())
        .environmentObject(GedungViewModel())
}
