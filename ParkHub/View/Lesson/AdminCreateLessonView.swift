// File: AdminCreateLessonView.swift
// ParkHub

import SwiftUI
import FirebaseAuth
// import Firebase // For FirebaseApp.configure() in preview, if needed by VMs

// Assuming Lesson, primaryOrange, logoutRed, TopAppBar, BotAppBar are defined
// Assuming AdminCreateLessonViewModel is defined and compatible

struct AdminCreateLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel // Needed if TopAppBar is used
    @EnvironmentObject var viewModel: AdminCreateLessonViewModel
    @Environment(\.dismiss) var dismiss // To dismiss the current view

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""

    let token: String // This might be redundant if userId is always from Auth.auth().currentUser?.uid
    var onLessonCreated: () -> Void
    var onShowError: (String) -> Void

    var body: some View {
        VStack(spacing: 0) { // Main VStack with no spacing for app bars
            TopAppBar() // Generic TopAppBar

            // Content Area
            ScrollView {
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

                    // "Create Lesson" Title
                    Text("Create Lesson")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the title

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
                    
                    if let error = viewModel.creationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.vertical, 5)
                    }

                    Button(action: attemptCreateLesson) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(height: 24) // Consistent height
                        } else {
                            Text("Create")
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
                .padding() // Padding for the form content inside ScrollView
            }
            .background(Color(UIColor.systemGroupedBackground)) // Background for the scrollable area

            BotAppBar() // Generic BotAppBar
        }
        .navigationBarHidden(true) // TopAppBar replaces the system nav bar
        .onChange(of: viewModel.creationSuccess) { newSuccessState in
            if newSuccessState {
                onLessonCreated()
                resetFormFields()
                viewModel.resetStatusFlags()
                // If onLessonCreated doesn't dismiss, you might call dismiss() here.
                // dismiss()
            }
        }
        .onChange(of: viewModel.creationError) { newErrorState in
            if let errorMessage = newErrorState, !errorMessage.isEmpty {
                onShowError(errorMessage)
            }
        }
    }

    private func attemptCreateLesson() {
        guard let userId = Auth.auth().currentUser?.uid else {
            onShowError("User not authenticated. Please sign in.")
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = contentText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty || trimmedDescription.isEmpty || trimmedContent.isEmpty {
            onShowError("Title, Description, and Content are required.")
            return
        }

        let newLesson = Lesson(
            // Assuming your Lesson struct has an initializer that omits `id` for creation,
            // or your backend assigns it. If `id` needs to be generated client-side:
            // id: UUID().uuidString, // Example if needed
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            userId: userId
        )
        
        // Regarding `self.token`:
        // If your `saveNewLesson` backend endpoint uses the user's Firebase ID token for authentication,
        // you should fetch it here: `Auth.auth().currentUser?.getIDTokenResult...`
        // If `self.token` was meant to be the `userId`, then `userId` from above is sufficient.
        // If `self.token` is a separate admin API token, then using it is correct.
        // For now, assuming `self.token` is an API token distinct from the user's session token/ID.
        viewModel.saveNewLesson(newLesson, token: self.token)
    }
    
    private func resetFormFields() {
        title = ""
        descriptionText = ""
        contentText = ""
    }
}

// Make sure primaryOrange is defined and accessible.
// For example, if it's not globally defined, you might add it for the preview or within your app's constants.
// let primaryOrange = Color.orange

// Ensure Lesson struct is defined, matching your data model (especially `userId` type and id handling for new lessons)
// struct Lesson: Identifiable {
//     var id: String? // Optional if assigned by backend
//     var title: String
//     var desc: String
//     var content: String
//     var userId: String
// }

// Ensure AdminCreateLessonViewModel and other dependencies are correctly defined.

#Preview {
    // Define a dummy primaryOrange for the preview if not globally available
    let primaryOrange = Color.orange

    NavigationView {
        AdminCreateLessonView(
            token: "dummy_admin_token_for_preview",
            onLessonCreated: { print("Preview: Lesson created!") },
            onShowError: { error in print("Preview Error: \(error)") }
        )
        .environmentObject(AuthViewModel()) // Dummy or real AuthViewModel
        .environmentObject(AdminCreateLessonViewModel()) // Dummy or real AdminCreateLessonViewModel
        // .environmentObject(ReportViewModel()) // If BotAppBar needs it
    }
}
