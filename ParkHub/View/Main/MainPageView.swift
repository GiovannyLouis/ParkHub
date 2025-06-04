// MainPageView.swift
// ParkHub
// Created by student on 03/06/25.

import SwiftUI

// Assuming AlertInfo is defined globally or imported
// struct AlertInfo: Identifiable { let id = UUID(); let message: String; let isError: Bool }

struct MainPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    @StateObject var directAdminCreateLessonVM = AdminCreateLessonViewModel() // Ensure this VM is defined
    @State private var adminActionAlertInfo: AlertInfo? // Ensure AlertInfo is defined
    
    @State private var showAuthSheet = false
    @State private var isRegistering = false
    
    @State private var showingSubmitReportSheet = false
    @State private var showingBrowseLessonsSheet = false
    
    private var isAdminUser: Bool {
        authVM.firebaseAuthUser?.email == "admin@gmail.com"
    }
    
    var body: some View {
        // The outer NavigationView might be removed if TopAppBar/BotAppBar
        // are meant to be the sole navigation system for this screen.
        // For now, let's keep it to allow NavigationLinks to work,
        // but we'll hide its bar if TopAppBar is present.
        NavigationView {
            VStack(spacing: 0) { // Use spacing: 0 to have app bars flush
                if authVM.isSignedIn {
                    TopAppBar() // Added TopAppBar
                    
                    ScrollView { // Main content is scrollable
                        VStack { // Content VStack
                            Text("Welcome to ParkHub!")
                                .font(.largeTitle)
                                .padding()
                            
                            if let user = authVM.firebaseAuthUser {
                                Text("Hello, \(user.displayName ?? user.email ?? "User")!")
                                    .font(.title2)
                                    .padding(.bottom)
                            }
                            
                            // --- Admin Specific Options ---
                            if isAdminUser {
                                Text("Admin Panel")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.top)
                                
                                NavigationLink {
                                    AdminManageLessonView( // Ensure AdminManageLessonView is defined
                                        token: authVM.firebaseAuthUser?.uid ?? "admin_token_error",
                                        onLogout: {
                                            authVM.signOut()
                                        }
                                    )
                                } label: {
                                    Label("Manage Lessons", systemImage: "slider.horizontal.3")
                                        .font(.headline)
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                                
                                NavigationLink {
                                    AdminCreateLessonView( // Ensure AdminCreateLessonView is defined
                                        token: authVM.firebaseAuthUser?.uid ?? "admin_token_error_direct_create",
                                        onLessonCreated: {
                                            self.adminActionAlertInfo = AlertInfo(message: "Lesson created successfully!", isError: false)
                                        },
                                        onShowError: { errorMessage in
                                            self.adminActionAlertInfo = AlertInfo(message: errorMessage, isError: true)
                                        }
                                    )
                                    .environmentObject(directAdminCreateLessonVM)
                                    .navigationTitle("Create New Lesson") // This title will be shown by NavigationView if its bar is visible
                                    .navigationBarTitleDisplayMode(.inline)
                                } label: {
                                    Label("Create New Lesson", systemImage: "plus.rectangle.on.folder")
                                        .font(.headline)
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                                
                                Divider().padding(.horizontal)
                            }
                            // --- End of Admin Specific Options ---
                            
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
                            
                            // NavigationLink to reportListView
                            NavigationLink {
                                reportListView() // Assuming reportListView is defined
                                    .navigationTitle("All Reports")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                Label("View All Reports", systemImage: "list.bullet.rectangle.fill")
                                    .font(.headline)
                            }
                            .padding()
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            // Button to show Lessons Section in a Sheet (for regular users)
                            Button {
                                showingBrowseLessonsSheet = true
                            } label: {
                                Label("Browse Lessons", systemImage: "book.closed.fill")
                                    .font(.headline)
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
                            // NavigationLink to LocationView
                            NavigationLink {
                                LocationView() // Destination is your LocationView
                            } label: {
                                Label("View Locations", systemImage: "map.fill")
                                    .font(.headline)
                            }
                            .padding()
                            .buttonStyle(.bordered)
                            .tint(.cyan)
                            
                            // Spacer() // Removed spacer to let content naturally flow, logout button is distinct
                            
                            Button("Log Out") {
                                authVM.signOut()
                            }
                            .padding() // Add vertical padding to separate from last item
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .padding(.bottom, 20) // Ensure some space before BotAppBar if content is short
                            
                        } // End of Content VStack
                        .padding(.horizontal) // Add some horizontal padding to the content inside ScrollView
                    } // End of ScrollView
                    
                    BotAppBar() // Added BotAppBar
                    
                } else {
                    // Content to show when the user IS NOT signed in (remains the same, no Top/BotAppBar)
                    // This section fills the whole screen.
                    // If you want a consistent background or structure even for the logged-out state,
                    // you might need to adjust this part.
                    ZStack { // Use ZStack to overlay LogoBig on a background
                        // Optional: Add a background color/image for the logged-out state
                        // Color.gray.opacity(0.1).ignoresSafeArea()
                        
                        VStack {
                            Spacer()
                            Button("Login / Register") {
                                authVM.clearInputFields()
                                authVM.clearAuthError()
                                self.showAuthSheet = true
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
                            
                            
                            Text("Please log in or register to continue.")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Spacer()
                        }
                    }
                }
            }
            // .navigationTitle("ParkHub") // This would be hidden by .navigationBarHidden(true)
            // .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(authVM.isSignedIn) // Hide system nav bar if signed in (TopAppBar is used)
            // Show system nav bar if not signed in (to show "ParkHub" title)
            .onAppear {
                if !authVM.isSignedIn && !showAuthSheet {
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
                AuthSheetContainerView(isRegisteringInitially: $isRegistering) // Ensure AuthSheetContainerView is defined
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showingSubmitReportSheet) {
                NavigationView { // Sheet content often has its own NavigationView
                    submitReportView() // Assuming submitReportView is defined
                }
            }
            .sheet(isPresented: $showingBrowseLessonsSheet) {
                NavigationView { // Sheet content often has its own NavigationView
                    LessonPageView() // Ensure LessonPageView is defined
                        .navigationTitle("Browse Lessons")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingBrowseLessonsSheet = false
                                }
                            }
                        }
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
            .alert(item: $adminActionAlertInfo) { info in
                Alert(
                    title: Text(info.isError ? "Error" : "Success"),
                    message: Text(info.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        } // End of NavigationView
        // If TopAppBar/BotAppBar are the primary navigation, the outer NavigationView might be removed
        // and replaced with a simple View or ZStack. NavigationLinks would then need to
        // be handled differently (e.g., by changing a @State var that swaps views, or using NavigationStack for sub-sections).
    }
}

// Ensure all referenced views and ViewModels are defined.
// Make sure AlertInfo, TopAppBar, BotAppBar, LogoBig, etc., are accessible.

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
    // Use placeholder views for dependencies if the actual ones are not available or too complex for preview
    // Replace _PreviewDummy with your actual views if they are simple enough for preview
    MainPageView()
        .environmentObject(AuthViewModel()) // Standard AuthViewModel instance
        .environmentObject(ReportViewModel())
    // Provide dummy views for the preview if needed, e.g. by renaming reportListView to reportListView_PreviewDummy
    // .environmentObject(LessonViewModel()) // If LessonPageView or its children need it
    // For the preview to compile, ensure that reportListView, submitReportView, LogoBig,
    // AuthSheetContainerView, and LessonPageView are either:
    // 1. Defined in a way that the preview can access them.
    // 2. Replaced by dummy versions for the preview scope (like the _PreviewDummy examples above).
    //    If using dummies, you would call reportListView_PreviewDummy() in the MainPageView body for the preview.
    //    This can be done with conditional compilation (#if DEBUG ... #else ... #endif) around the view calls
    //    in MainPageView's body, or by ensuring the preview target has access to simple dummy views.
    //    The current setup assumes the actual views are accessible.
}
