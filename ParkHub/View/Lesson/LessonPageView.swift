// File: LessonPageView.swift
// ParkHub

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
let logoutRed = Color(hex: 0xFFD9534F)
let primaryOrange = Color(hex: 0xffffa001)

// File: LessonPageView.swift
// ParkHub


// Ensure your Color extension and color constants (primaryOrange, logoutRed)
// are defined globally or in a shared file accessible here.
// Example:
// extension Color {
//    init(hex: UInt, alpha: Double = 1) { /* ... */ }
// }
// let primaryOrange = Color(hex: 0xffffa001)
// let logoutRed = Color(hex: 0xFFD9534F)
// Assume TopAppBar, BotAppBar, LessonCardView are defined.
// Assume Lesson struct is defined.

struct LessonPageView: View {
    @EnvironmentObject var authVM: AuthViewModel // For TopAppBar and getting user ID
    @StateObject var lessonVM = LessonViewModel() // ViewModel to fetch and hold lessons

    // The 'token' prop is no longer needed if we fetch using authVM.currentUser.uid in onAppear.
    // var token: String

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar() // Uses authVM from environment

            // Content based on LessonViewModel's state
            if lessonVM.isLoading {
                Spacer()
                ProgressView("Loading lessons...")
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                    .scaleEffect(1.5)
                Spacer()
            } else if let message = lessonVM.errorMessage {
                Spacer()
                VStack { // Added VStack for better layout of error message and retry
                    Text(message)
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Try Again") {
                        lessonVM.fetchAllLessons()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(primaryOrange)
                }
                Spacer()
            } else if lessonVM.lessons.isEmpty { // No error, but no lessons
                Spacer()
                VStack {
                    Text("No lessons available at the moment.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding()
                    Button("Refresh") {
                        lessonVM.fetchAllLessons()
                    }
                    .padding()
                    .buttonStyle(.bordered)
                }
                Spacer()
            } else {
                // Display the list of lessons from the ViewModel
                List {
                    ForEach(lessonVM.lessons) { lesson in // Iterate over lessonVM.lessons
                        LessonCardView(lesson: lesson) // Ensure LessonCardView is defined
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable { // Pull-to-refresh
                    lessonVM.fetchAllLessons()
                }
            }
            
            BotAppBar() // BotAppBar for navigation
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            // Fetch lessons only if the list is currently empty and not already loading
            if lessonVM.lessons.isEmpty && !lessonVM.isLoading {
                lessonVM.fetchAllLessons()
            }
        }
        .onDisappear {
            // If your LessonViewModel uses Firebase observers that need explicit removal
            // lessonVM.removeObservers()
        }
        // .navigationBarHidden(true) // This view has its own TopAppBar, so hide system nav bar
                                   // if this view is pushed onto a NavigationView stack.
    }
}

// Ensure Lesson, LessonCardView, TopAppBar, BotAppBar, AuthViewModel, LessonViewModel are defined.
// Ensure color constants like primaryOrange are defined.

#Preview {
    NavigationView { // For BotAppBar links & TopAppBar context
        LessonPageView(
            // token prop removed, fetching logic is internal
        )
        .environmentObject(AuthViewModel()) // Use mock for preview if needed
        .environmentObject(ReportViewModel()) // If BotAppBar's report link is tested
        // LessonViewModel is @StateObject within LessonPageView, so no need to inject here
        // unless child views (navigated to from LessonCardView) need to share THIS instance.
    }
}

// Add mockSignedIn to AuthViewModel for preview if not already present
#if DEBUG
// extension AuthViewModel {
//    static func mockSignedIn() -> AuthViewModel {
//        let vm = AuthViewModel()
//        vm.isSignedIn = true
//        // vm.firebaseAuthUser = ... // mock FirebaseUser if needed for displayName/email
//        return vm
//    }
// }
#endif
