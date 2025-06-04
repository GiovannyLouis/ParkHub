// File: AdminUpdateLessonView.swift

import SwiftUI
import Firebase
import FirebaseAuth
// For Auth.auth().currentUser?.uid
// No need for FirebaseAuth directly if only using Auth.auth()

// Assuming primaryOrange, logoutRed, Lesson, TopAppBar, BotAppBar are defined
// Assuming AdminUpdateLessonViewModel is defined and compatible

struct AdminUpdateLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel // For TopAppBar
    @EnvironmentObject var viewModel: AdminUpdateLessonViewModel
    @Environment(\.dismiss) var dismiss // To dismiss the current view

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""
    @State private var originalUserId: String? = nil // For preserving original author if needed

    @State private var isFetchingDetails: Bool = false

    let lessonId: String
    var onLessonUpdated: () -> Void // Callback on successful update
    var onShowError: (String) -> Void // Callback to show an error message

    var body: some View {
        VStack(spacing: 0) { // Main VStack with no spacing for app bars
            TopAppBar() // Generic TopAppBar

            // Content Area
            ScrollView {
                if isFetchingDetails {
                    ProgressView("Loading lesson details...")
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange)) // Ensure primaryOrange is defined
                        .padding(.top, 50)
                } else {
                    // Form content
                    VStack(alignment: .leading, spacing: 16) {

                        // --- Custom Back Button ---
                        Button(action: {
                            dismiss() // Action to go back
                        }) {
                            HStack(spacing: 4) { // Adjust spacing as needed
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold)) // Style similar to navigation bar back button
                                Text("Back")
                                    .font(.system(size: 17))
                            }
                        }
                        .foregroundColor(primaryOrange) // Use your app's accent color, ensure primaryOrange is defined
                        .padding(.bottom, 10) // Add some space below the back button before the title

                        // "Update Lesson" Title
                        Text("Update Lesson")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 5)
                            .frame(maxWidth: .infinity, alignment: .center) // Center the title

                        Text("Lesson ID: \(lessonId)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)

                        Group {
                            Text("Title:")
                                .font(.headline)
                            TextField("Enter title here", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)

                            Text("Description:")
                                .font(.headline)
                            TextField("Enter description here", text: $descriptionText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)

                            Text("Content:")
                                .font(.headline)
                            TextEditor(text: $contentText)
                                .frame(height: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .padding(.bottom, 5)
                        }
                        
                        if let error = viewModel.updateError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 5)
                        }

                        Button(action: attemptUpdateLesson) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 24) // Consistent height for ProgressView
                            } else {
                                Text("Update")
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(primaryOrange) // Ensure primaryOrange is defined
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding() // Padding for all form content inside ScrollView
                }
            }
            .background(Color(UIColor.systemGroupedBackground)) // Background for the scrollable area

            BotAppBar() // Generic BotAppBar
        }
        .onAppear(perform: loadLessonDetails)
        .navigationBarHidden(true) // TopAppBar replaces the system navigation bar
    }

    private func loadLessonDetails() {
        isFetchingDetails = true
        viewModel.fetchLessonDetails(lessonId: lessonId) { result in
            isFetchingDetails = false
            switch result {
            case .success(let lesson):
                self.title = lesson.title
                self.descriptionText = lesson.desc
                self.contentText = lesson.content
                self.originalUserId = lesson.userId
            case .failure(let error):
                onShowError("Failed to load lesson details: \(error.localizedDescription)")
                // Optionally dismiss if details can't be loaded:
                // dismiss()
            }
        }
    }

    private func attemptUpdateLesson() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = contentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty || trimmedDescription.isEmpty || trimmedContent.isEmpty {
            onShowError("Title, Description, and Content are required.")
            return
        }
        
        // Use the originalUserId if available; otherwise, assign the current admin's UID.
        // This assumes that if originalUserId is nil, the admin is effectively "claiming" or setting the owner.
        let userIdForUpdate: String? = self.originalUserId ?? Auth.auth().currentUser?.uid

        let updatedLesson = Lesson(
            id: lessonId,
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            userId: userIdForUpdate // Ensure your Lesson struct and backend can handle this userId logic
        )
        
        viewModel.updateExistingLesson(updatedLesson,
            onSuccess: {
                onLessonUpdated() // This should trigger UI update/dismissal in the parent view
                viewModel.resetStatusFlags()
                // If onLessonUpdated doesn't cause dismissal, you might call dismiss() here too.
                // dismiss()
            },
            onError: { errorMessage in
                onShowError(errorMessage)
            }
        )
    }
}

// Make sure primaryOrange is defined and accessible.
// For example, if it's not globally defined, you might add it for the preview or within your app's constants.
// let primaryOrange = Color.orange

// Ensure Lesson struct is defined, matching your data model (especially `userId` type)
// struct Lesson: Identifiable {
//     var id: String
//     var title: String
//     var desc: String
//     var content: String
//     var userId: String? // Or String, depending on requirements
// }

// Ensure AdminUpdateLessonViewModel and other dependencies are correctly defined.

#Preview {
    // Define a dummy primaryOrange for the preview if not globally available
    let primaryOrange = Color.orange

    NavigationView {
        AdminUpdateLessonView(
            lessonId: "previewLesson123",
            onLessonUpdated: { print("Preview: Lesson updated!") },
            onShowError: { error in print("Preview Error: \(error)") }
        )
        .environmentObject(AuthViewModel()) // Dummy or real AuthViewModel
        .environmentObject(AdminUpdateLessonViewModel()) // Dummy or real AdminUpdateLessonViewModel
        // .environmentObject(ReportViewModel()) // If BotAppBar needs it
    }
}
