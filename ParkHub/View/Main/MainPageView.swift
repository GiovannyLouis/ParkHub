import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var locationVM: LocationViewModel
    @EnvironmentObject var adminLessonVM: AdminLessonViewModel

    @State private var adminActionAlertInfo: AlertInfo?
    @State private var showAuthSheet = false
    @State private var isRegistering = false


    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isAdminUser: Bool {
        authVM.firebaseAuthUser?.email == "admin@gmail.com"
    }

    var body: some View {
        NavigationView {
            Group {
                if authVM.isSignedIn {
                    VStack(spacing: 0) {
                        TopAppBar()

                        ScrollView {
                            VStack(spacing: 32) {
                                VStack(spacing: 12) {
                                    Text("Welcome to ParkHub!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)

                                    if let user = authVM.firebaseAuthUser {
                                        Text("Hello, \(user.displayName ?? user.email ?? "User")!")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal)
                                
                                VStack(spacing: 16) {
                                            HStack {
                                                Text("Parking Availability")
                                                    .font(.title2)
                                                    .fontWeight(.semibold)
                                                Spacer()
                                            }
                                            
                                            VStack(spacing: 12) {
                                                AvailabilityCard(
                                                    title: "Gedung",
                                                    availableCount: locationVM.availableGedungSpots,
                                                    totalCount: locationVM.totalGedungSpots,
                                                    icon: "building.2.fill",
                                                    color: .blue
                                                )
                                                AvailabilityCard(
                                                    title: "Lapangan",
                                                    availableCount: locationVM.availableLapanganSpots,
                                                    totalCount: locationVM.totalLapanganSpots,
                                                    icon: "car.2.fill",
                                                    color: .green
                                                )
                                                AvailabilityCard(
                                                    title: "Bukit",
                                                    availableCount: locationVM.availableBukitSpots,
                                                    totalCount: locationVM.totalBukitSpots,
                                                    icon: "mountain.2.fill",
                                                    color: .orange
                                                )
                                            }
                                        }
                                        .padding(.horizontal)

                                if isAdminUser {
                                    VStack(spacing: 20) {
                                        HStack {
                                            Text("Admin Panel")
                                                .font(.title2)
                                                .fontWeight(.semibold)
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
                                                .environmentObject(authVM)
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

                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Quick Actions")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.horizontal)

                                    LazyVGrid(columns: horizontalSizeClass == .regular ?
                                               [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] :
                                               [GridItem(.flexible()), GridItem(.flexible())],
                                               spacing: 20) {
                                        NavigationLink {
                                            submitReportView()
                                                .navigationTitle("Create Report")
                                                .navigationBarTitleDisplayMode(.inline)
                                                .onAppear {
                                                    reportVM.clearInputFields()
                                                }
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

                                        NavigationLink {
                                            LessonPageView()
                                                .navigationTitle("Browse Lessons")
                                                .navigationBarTitleDisplayMode(.inline)
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
                            .padding(.bottom, 20)
                        }

                        BotAppBar()
                    }
                } else {
                    ZStack {
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()

                        VStack(spacing: 30) {
                            Spacer()

                            VStack(spacing: 16) {
                                Text("Welcome to ParkHub")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)

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
                        if !authVM.isSignedIn {
                            showAuthSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showAuthSheet) {
                if !authVM.isSignedIn {
                    AuthSheetContainerView(isRegisteringInitially: $isRegistering)
                        .environmentObject(authVM)
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
        .navigationViewStyle(StackNavigationViewStyle())
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


struct AvailabilityCard: View {
    let title: String
    let availableCount: Int
    let totalCount: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            HStack(alignment: .lastTextBaseline) {
                Text("\(availableCount)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(" / \(totalCount) spots")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text("Available")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    MainPageView()
        .environmentObject(AuthViewModel())
        .environmentObject(ReportViewModel()) // Add ReportViewModel for preview
        .environmentObject(LocationViewModel())
        .environmentObject(ReportViewModel())
        .environmentObject(AdminLessonViewModel())
}
