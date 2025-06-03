//
//  AdminManageLessonView.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


import SwiftUI
import Firebase 

struct AdminManageLessonView: View {
    @StateObject var viewModel: AdminManageLessonViewModel

    let token: String
    var onLogout: () -> Void
    var onNavigateToUpdateLesson: (String) -> Void
    var onNavigateToCreateLesson: () -> Void
    var onShowMessage: (String, Bool) -> Void // (message, isError)

    init(viewModel: AdminManageLessonViewModel = AdminManageLessonViewModel(),
         token: String,
         onLogout: @escaping () -> Void,
         onNavigateToUpdateLesson: @escaping (String) -> Void,
         onNavigateToCreateLesson: @escaping () -> Void,
         onShowMessage: @escaping (String, Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.token = token
        self.onLogout = onLogout
        self.onNavigateToUpdateLesson = onNavigateToUpdateLesson
        self.onNavigateToCreateLesson = onNavigateToCreateLesson
        self.onShowMessage = onShowMessage
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Top Bar (UI remains the same)
                VStack {
                    HStack {
                        LogoSmall() // Assuming defined
                        Spacer()
                        Button(action: onLogout) {
                            Text("Logout")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .background(logoutRed) // Assuming defined
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
                }
                .frame(maxWidth: .infinity)
                .background(primaryOrange) // Assuming defined
                .edgesIgnoringSafeArea(.top)

                // Content Area
                if viewModel.isLoading && viewModel.lessons.isEmpty { // Show loading only if lessons are not yet loaded
                    Spacer()
                    ProgressView("Loading lessons...")
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let error = viewModel.errorMessage, viewModel.lessons.isEmpty { // Show error only if no lessons to display
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if viewModel.lessons.isEmpty { // No error, but lessons array is empty
                    Spacer()
                    Text("No lessons available. Tap '+' to create one.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.lessons) { lesson in // Directly observe viewModel.lessons
                            AdminLessonCard(
                                lesson: lesson,
                                onUpdate: { onNavigateToUpdateLesson(lesson.id) },
                                onDelete: {
                                    // Call ViewModel's delete method
                                    viewModel.deleteLesson(
                                        token: token, // Token might be for API auth, not directly Firebase DB
                                        lessonId: lesson.id,
                                        onSuccess: {
                                            onShowMessage("Lesson deleted successfully!", false)
                                            // No need to call fetchAllLessons again if using .observe
                                        },
                                        onError: { errorMessage in
                                            onShowMessage(errorMessage, true)
                                        }
                                    )
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable { // Optional: Add pull-to-refresh
                        viewModel.fetchAllLessons(token: token)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                viewModel.fetchAllLessons(token: token)
            }
            // .onDisappear {
            //     viewModel.stopListeningForLessons() // Optional: if you want to stop listening when view disappears
            // }

            // FAB (UI remains the same)
            Button(action: onNavigateToCreateLesson) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(primaryOrange) // Assuming defined
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

// AdminLessonCard remains the same as it's UI only
struct AdminLessonCard: View {
    let lesson: Lesson
    var onUpdate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lesson.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            Spacer().frame(height: 8)
            Text(lesson.desc)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineLimit(3)
            Spacer().frame(height: 16)
            HStack(spacing: 8) {
                Button(action: onUpdate) {
                    Text("Update")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(primaryOrange) // Assuming defined
                        .cornerRadius(8)
                }
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(logoutRed) // Assuming defined
                        .cornerRadius(8)
                }
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


struct AdminManageLessonView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure Firebase is configured for previews
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Mock ViewModel for preview to control data
        class MockAdminManageLessonViewModel: AdminManageLessonViewModel {
            override func fetchAllLessons(token: String) {
                self.isLoading = false
                self.lessons = [
                    Lesson(id: "preview1", title: "Intro to SwiftUI (Preview)", desc: "Learn the basics of SwiftUI.", content: "Full content...", userId: "admin1"),
                    Lesson(id: "preview2", title: "Advanced State Management (Preview)", desc: "Deep dive into Combine and @StateObject.", content: "More content...", userId: "admin1")
                ]
            }
            override func deleteLesson(token: String, lessonId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
                if let index = self.lessons.firstIndex(where: { $0.id == lessonId }) {
                    self.lessons.remove(at: index)
                    onSuccess()
                } else {
                    onError("Preview lesson not found.")
                }
            }
        }
        
        return AdminManageLessonView(
            viewModel: MockAdminManageLessonViewModel(), // Use the mock VM
            token: "dummy_token_preview",
            onLogout: { print("Preview: Logout tapped") },
            onNavigateToUpdateLesson: { lessonId in print("Preview: Navigate to update lesson \(lessonId)") },
            onNavigateToCreateLesson: { print("Preview: Navigate to create lesson") },
            onShowMessage: { message, isError in print("Preview: Message - \(message), IsError - \(isError)") }
        )
        // If AdminManageLessonViewModel was changed to be an @EnvironmentObject,
        // you would use .environmentObject(MockAdminManageLessonViewModel()) here.
    }
}
