// File: AdminManageLessonView.swift
// ParkHub

import SwiftUI

// Define AlertInfo if not already globally available
struct AlertInfo: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}
// File: AdminManageLessonView.swift
// ParkHub

import SwiftUI

// Assume AlertInfo is defined globally or in a shared file
// struct AlertInfo: Identifiable { /* ... */ }

// Assume Lesson, primaryOrange, logoutRed, TopAppBar, BotAppBar, LogoSmall, AdminLessonCard are defined
// Assume ViewModels (AdminManageLessonViewModel, AdminCreateLessonViewModel, AdminUpdateLessonViewModel) are defined

struct AdminManageLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel // Needed for TopAppBar
    @Environment(\.dismiss) var dismiss // For the custom back button
    
    @StateObject var viewModel = AdminManageLessonViewModel() // For fetching/deleting lessons
    @StateObject var createLessonVM = AdminCreateLessonViewModel() // For AdminCreateLessonView
    @StateObject var updateLessonVM = AdminUpdateLessonViewModel() // For AdminUpdateLessonView
    
    let token: String
    // The onLogout parameter is now redundant if TopAppBar handles logout,
    // but we'll keep it if you want the option for a different logout action from here.
    // If TopAppBar's logout is sufficient, this can be removed.
    var onLogout: () -> Void
    
    @State private var showCreateLessonView = false
    @State private var lessonIdToUpdate: String? = nil
    @State private var alertInfo: AlertInfo?
    
    var body: some View {
        VStack(spacing: 0) { // Main VStack with no spacing for app bars
            TopAppBar() // Generic TopAppBar with LogoSmall and Logout
            
            ZStack(alignment: .bottomTrailing) {
                // Content Area (List or messages)
                VStack(alignment: .leading, spacing: 0) { // Inner VStack for content area

                    // --- Custom Back Button ---
                    // Positioned at the top of the content area, below TopAppBar.
                    Button(action: {
                        dismiss() // Action to go back
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(primaryOrange) // Ensure primaryOrange is defined
                    }
                    .padding([.leading, .top]) // Give it some padding from the edges
                    .padding(.bottom, 10)   // Space below the back button before other content

                    // The rest of the content
                    if viewModel.isLoading && viewModel.lessons.isEmpty {
                        Spacer() // Pushes ProgressView to center of remaining space
                        ProgressView("Loading lessons...")
                            .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, alignment: .center) // Ensure ProgressView itself is centered
                        Spacer()
                    } else if let error = viewModel.errorMessage, viewModel.lessons.isEmpty {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else if viewModel.lessons.isEmpty {
                        Spacer()
                        Text("No lessons available. Tap '+' to create one.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.lessons) { lesson in
                                AdminLessonCard(
                                    lesson: lesson,
                                    onUpdate: {
                                        self.lessonIdToUpdate = lesson.id
                                    },
                                    onDelete: {
                                        viewModel.deleteLesson(
                                            token: token,
                                            lessonId: lesson.id, // Ensure lesson.id is a String
                                            onSuccess: {
                                                self.alertInfo = AlertInfo(message: "Lesson deleted successfully!", isError: false)
                                                viewModel.fetchAllLessons(token: token)
                                            },
                                            onError: { errorMessage in
                                                self.alertInfo = AlertInfo(message: errorMessage, isError: true)
                                            }
                                        )
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            viewModel.fetchAllLessons(token: token)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure this VStack fills available space
                .background(Color(UIColor.systemGroupedBackground)) // Background for the list area
                .onAppear {
                    viewModel.fetchAllLessons(token: token)
                }
                
                // FAB to trigger create lesson NavigationLink
                Button(action: {
                    self.showCreateLessonView = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(primaryOrange) // Ensure primaryOrange is defined
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding() // Padding for the FAB from the edges
                
                // Hidden NavigationLinks (remain the same)
                NavigationLink(
                    destination: AdminCreateLessonView(
                        token: token,
                        onLessonCreated: {
                            self.showCreateLessonView = false
                            self.alertInfo = AlertInfo(message: "Lesson created successfully!", isError: false)
                            viewModel.fetchAllLessons(token: token)
                        },
                        onShowError: { errorMessage in
                            self.alertInfo = AlertInfo(message: errorMessage, isError: true)
                        }
                    )
                    .environmentObject(authVM)
                    .environmentObject(createLessonVM),
                    isActive: $showCreateLessonView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: AdminUpdateLessonView(
                        lessonId: lessonIdToUpdate ?? "",
                        onLessonUpdated: {
                            self.lessonIdToUpdate = nil
                            self.alertInfo = AlertInfo(message: "Lesson updated successfully!", isError: false)
                            viewModel.fetchAllLessons(token: token)
                        },
                        onShowError: { errorMessage in
                            self.alertInfo = AlertInfo(message: errorMessage, isError: true)
                        }
                    )
                    .environmentObject(authVM)
                    .environmentObject(updateLessonVM),
                    isActive: Binding<Bool>(
                        get: { self.lessonIdToUpdate != nil },
                        set: { isActive in
                            if !isActive {
                                self.lessonIdToUpdate = nil
                            }
                        }
                    )
                ) { EmptyView() }
            } // End of ZStack for content and FAB
            
            BotAppBar() // Generic BotAppBar
        }
        .navigationBarHidden(true) // TopAppBar replaces the system navigation bar
        .alert(item: $alertInfo) { info in
            Alert(
                title: Text(info.isError ? "Error" : "Success"),
                message: Text(info.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// AdminLessonCard definition (ensure it's available)
// Assume Lesson, primaryOrange, logoutRed are defined elsewhere or passed appropriately
// struct AdminLessonCard: View { /* ... */ }

// Define necessary colors and LogoSmall if not global
// let primaryOrange = Color.orange // Ensure this is defined globally or where AdminLessonCard uses it
// let logoutRed = Color.red       // Ensure this is defined globally or where AdminLessonCard uses it
// struct LogoSmall: View { /* ... */ }

// Define Lesson struct
// struct Lesson: Identifiable { /* ... var id: String ... */ } // Ensure Lesson and its id type are defined

// Define ViewModels
// class AdminManageLessonViewModel: ObservableObject { /* ... @Published var lessons ... fetchAllLessons ... deleteLesson ... */ }
// class AdminCreateLessonViewModel: ObservableObject { /* ... */ }
// class AdminUpdateLessonViewModel: ObservableObject { /* ... */ }


// ... (within AdminManageLessonView.swift or a related file)
struct AdminLessonCard: View {
    let lesson: Lesson // Ensure Lesson struct has title, desc, and id (String)
    var onUpdate: () -> Void
    var onDelete: () -> Void
    
    // These colors would ideally be globally defined or passed in
    // For the sake of this example, if they aren't, the code might not compile without them.
    // To make AdminLessonCard standalone for compilation, you might need to define them:
    // let primaryOrange = Color.orange
    // let logoutRed = Color.red
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lesson.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(lesson.desc)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineLimit(3)
            HStack(spacing: 10){ // Added spacing for clarity
                Button(action: onUpdate) {
                    Text("Update")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(primaryOrange) // Ensure primaryOrange is defined
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
                .contentShape(Rectangle())
                
                
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(logoutRed) // Ensure logoutRed is defined
                        .cornerRadius(8)
                }
                .buttonStyle(.borderless)
                .contentShape(Rectangle())

            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        
    }
}

#Preview { // Reverted to your original preview structure
    NavigationView { // NavigationView for BotAppBar links and context
        AdminManageLessonView(
            token: "preview_admin_token",
            onLogout: {
                print("Preview: AdminManageLessonView onLogout called (may be redundant if TopAppBar handles it)")
            }
        )
        .environmentObject(AuthViewModel()) // For TopAppBar and potentially child views
        // Note: AdminManageLessonView creates its own @StateObjects for AdminCreateLessonViewModel and AdminUpdateLessonViewModel
        // If AdminManageLessonViewModel, AdminCreateLessonViewModel, or AdminUpdateLessonViewModel are needed for the preview
        // and not created by AdminManageLessonView itself (which they are for this view), you would add them here.
        // .environmentObject(AdminManageLessonViewModel()) // This is created by AdminManageLessonView as @StateObject
        // .environmentObject(AdminCreateLessonViewModel()) // This is created by AdminManageLessonView as @StateObject
        // .environmentObject(AdminUpdateLessonViewModel()) // This is created by AdminManageLessonView as @StateObject
    }
}
