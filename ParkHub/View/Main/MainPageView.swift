import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var reportVM: ReportViewModel // For submitting reports

    @EnvironmentObject var bukitVM: BukitViewModel
    @EnvironmentObject var lapanganVM: LapanganViewModel
    @EnvironmentObject var gedungVM: GedungViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    @EnvironmentObject var adminLessonVM: AdminLessonViewModel
    
    @State private var adminActionAlertInfo: AlertInfo? // Make sure AlertInfo is defined
    
    @State private var showAuthSheet = false
    @State private var isRegistering = false
    
    @State private var showingSubmitReportSheet = false
    @State private var showingBrowseLessonsSheet = false
    
    private var isAdminUser: Bool {
        authVM.firebaseAuthUser?.email == "admin@gmail.com"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if authVM.isSignedIn {
                    TopAppBar()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Welcome Header Section
                            VStack(spacing: 12) {
                                Text("Welcome to ParkHub!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if let user = authVM.firebaseAuthUser {
                                    Text("Hello, \(user.displayName ?? user.email ?? "User")!")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                            
                            // Admin Panel Section
                            if isAdminUser {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Admin Panel")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 12) {
                                        NavigationLink {
                                            AdminManageLessonView(
                                                token: authVM.firebaseAuthUser?.uid ?? "admin_token_error",
                                                onLogout: {
                                                    authVM.signOut()
                                                }
                                            )
                                            .environmentObject(authVM)
                                        } label: {
                                            HomeActionCard(
                                                title: "Manage Lessons",
                                                icon: "slider.horizontal.3",
                                                subtitle: "Edit and organize lessons"
                                            )
                                        }
                                        
                                        NavigationLink {
                                            AdminCreateLessonView(
                                                token: authVM.firebaseAuthUser?.uid ?? "admin_token_error_direct_create",
                                                onLessonCreated: {
                                                    self.adminActionAlertInfo = AlertInfo(message: "Lesson created successfully!", isError: false)
                                                },
                                                onShowError: { errorMessage in
                                                    self.adminActionAlertInfo = AlertInfo(message: errorMessage, isError: true)
                                                }
                                            )
                                            .environmentObject(authVM) // Pass AdminLessonViewModel here too

                                            
                                            .navigationTitle("Create New Lesson")
                                            .navigationBarTitleDisplayMode(.inline)
                                        } label: {
                                            HomeActionCard(
                                                title: "Create New Lesson",
                                                icon: "plus.rectangle.on.folder",
                                                subtitle: "Add new educational content"
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                            
                            // Main Actions Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Quick Actions")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    Button {
                                        reportVM.clearInputFields()
                                        showingSubmitReportSheet = true
                                    } label: {
                                        HomeGridCard(
                                            title: "Create Report",
                                            icon: "plus.circle.fill",
                                            color: .blue
                                        )
                                    }
                                    
                                    NavigationLink {
                                        reportListView()
                                            .navigationTitle("All Reports")
                                            .navigationBarTitleDisplayMode(.inline)
                                    } label: {
                                        HomeGridCard(
                                            title: "View Reports",
                                            icon: "list.bullet.rectangle.fill",
                                            color: .blue
                                        )
                                    }
                                    
                                    Button {
                                        showingBrowseLessonsSheet = true
                                    } label: {
                                        HomeGridCard(
                                            title: "Browse Lessons",
                                            icon: "book.closed.fill",
                                            color: .blue
                                        )
                                    }
                                    
                                    NavigationLink {
                                        LocationView()
                                    } label: {
                                        HomeGridCard(
                                            title: "View Locations",
                                            icon: "map.fill",
                                            color: .blue
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 40)
                            
                        }
                    }
                    
                    BotAppBar()
                    
                } else {
                    // Logged out state
                    ZStack {
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 30) {
                            Spacer()
                            
                            VStack(spacing: 16) {
                                Text("Welcome to ParkHub")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Please log in or register to continue.")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button("Login / Register") {
                                authVM.clearInputFields()
                                authVM.clearAuthError()
                                self.showAuthSheet = true
                            }
                            .frame(maxWidth: 200)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(authVM.isSignedIn)
            .onAppear {
                if !authVM.isSignedIn && !showAuthSheet {
                    isRegistering = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !authVM.isSignedIn {  // Double check user still not signed in
                            showAuthSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showAuthSheet, onDismiss: {
                if !authVM.isSignedIn {
                    print("Auth sheet dismissed, user still not signed in.")
                }
            }) {
                if !authVM.isSignedIn {
                    AuthSheetContainerView(isRegisteringInitially: $isRegistering)
                        .environmentObject(authVM)
                }
            }
            .sheet(isPresented: $showingSubmitReportSheet) {
                NavigationView {
                    submitReportView()
                }
            }
            .sheet(isPresented: $showingBrowseLessonsSheet) {
                NavigationView {
                    LessonPageView()
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
                            if !authVM.isSignedIn {
                                showAuthSheet = true
                            }
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
        }
    }
}

// MARK: - Supporting Views

struct HomeActionCard: View {
    let title: String
    let icon: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HomeGridCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

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
        .environmentObject(BukitViewModel())
        .environmentObject(LapanganViewModel())
        .environmentObject(GedungViewModel())
        .environmentObject(ReportViewModel())
        .environmentObject(AdminLessonViewModel())
}
