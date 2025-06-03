//
//  AdminCreateLessonView.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


import SwiftUI
import FirebaseAuth // For Auth.auth().currentUser?.uid
import Firebase

struct AdminCreateLessonView: View {
    @EnvironmentObject var viewModel: AdminCreateLessonViewModel // Use EnvironmentObject
    @Environment(\.dismiss) var dismiss // Common for views that can be dismissed

    // Form fields as @State, like AddPageView
    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""
    @State private var imageUrlText: String = ""

    let token: String // Still passed, might be used by VM or for other purposes
    var onLessonCreated: () -> Void
    var onShowError: (String) -> Void

    // Removed custom init as viewModel is now an @EnvironmentObject

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar (UI remains the same)
            VStack {
                HStack {
                    Text("Create Lesson")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.orange) // Or your primaryOrange
            .edgesIgnoringSafeArea(.top)

            // Content Area (UI remains the same, bindings change to @State)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Title:")
                            .font(.headline)
                        TextField("Enter title here", text: $title) // Bind to @State
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 5)

                        Text("Description:")
                            .font(.headline)
                        TextField("Enter description here", text: $descriptionText) // Bind to @State
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 5)

                        Text("Content:")
                            .font(.headline)
                        TextEditor(text: $contentText) // Bind to @State
                            .frame(height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.bottom, 5)

                        Text("Image URL (optional):")
                            .font(.headline)
                        TextField("Enter image URL here", text: $imageUrlText) // Bind to @State
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 5)
                    }
                    
                    // Error message is displayed reactively based on viewModel.creationError
                    if let error = viewModel.creationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.vertical, 5)
                    }

                    Button(action: attemptCreateLesson) { // Call local private function
                        if viewModel.isLoading { // Still observe VM for loading state
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
                    .background(Color.orange) // Or your primaryOrange
                    .cornerRadius(8)
                    // Disable button if loading or essential fields are empty
                    .disabled(viewModel.isLoading || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.creationSuccess) { newSuccessState in
            if newSuccessState {
                onLessonCreated() // Call the provided closure
                resetFormFields() // Reset local @State fields
                viewModel.resetStatusFlags() // Tell VM to reset its success flag
            }
        }
        .onChange(of: viewModel.creationError) { newErrorState in
            if let errorMessage = newErrorState, !errorMessage.isEmpty {
                onShowError(errorMessage)
                // Optionally, tell VM to reset its error flag after showing
                // viewModel.resetStatusFlags() // or a more specific error reset
            }
        }
    }

    private func attemptCreateLesson() {
        // This function is now similar in style to AddPageView's saveFoodSpot()
        guard let userId = Auth.auth().currentUser?.uid else {
            onShowError("User not authenticated. Please sign in.")
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImageUrl = imageUrlText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Client-side validation (can be more extensive if needed)
        if trimmedTitle.isEmpty || trimmedDescription.isEmpty || trimmedContent.isEmpty {
            // This is also checked by the button's disabled state, but good for explicit error
            onShowError("Title, Description, and Content are required.")
            return
        }

        // Create the Lesson object in the View
        let newLesson = Lesson(
            // id is auto-generated by Lesson struct's default UUID().uuidString
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            imageUrl: trimmedImageUrl.isEmpty ? nil : trimmedImageUrl,
            userId: userId // Assign current user's ID
        )
        
        // Call the ViewModel method, passing the created Lesson object
        viewModel.saveNewLesson(newLesson, token: token)
        // The .onChange blocks will handle the asynchronous result (success/error)
    }
    
    private func resetFormFields() {
        title = ""
        descriptionText = ""
        contentText = ""
        imageUrlText = ""
    }
}

struct AdminCreateLessonView_Previews: PreviewProvider {
    static var previews: some View {
        // Configure Firebase specifically for this preview if not already done globally
        // in a way that affects previews.
        if FirebaseApp.app() == nil { // Check if Firebase is already configured
            FirebaseApp.configure()
        }
        
        return AdminCreateLessonView(
            token: "dummy_token",
            onLessonCreated: { print("Lesson created!") },
            onShowError: { error in print("Error: \(error)") }
        )
        .environmentObject(AdminCreateLessonViewModel())
    }
}

