//
//  is.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


import SwiftUI
import Firebase
import FirebaseAuth

// Assuming primaryOrange is defined
// Assuming Lesson struct is defined
/*
struct Lesson: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var desc: String
    var content: String
    var imageUrl: String?
    var userId: String?
}
*/

struct AdminUpdateLessonView: View {
    @EnvironmentObject var viewModel: AdminUpdateLessonViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""
    @State private var originalImageUrl: String? = nil
    @State private var originalUserId: String? = nil

    @State private var isFetchingDetails: Bool = false

    // Removed token from here
    let lessonId: String
    var onLessonUpdated: () -> Void
    var onShowError: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            VStack {
                HStack {
                    Text("Update Lesson")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
            }
            .frame(maxWidth: .infinity)
            .background(primaryOrange)
            .edgesIgnoringSafeArea(.top)

            ScrollView {
                if isFetchingDetails {
                    ProgressView("Loading lesson details...")
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lesson ID: \(lessonId)")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)

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
                                    .frame(height: 24)
                            } else {
                                Text("Update")
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(primaryOrange)
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear(perform: loadLessonDetails)
        .navigationBarHidden(true)
    }

    private func loadLessonDetails() {
        isFetchingDetails = true
        // No token passed to VM method
        viewModel.fetchLessonDetails(lessonId: lessonId) { result in
            isFetchingDetails = false
            switch result {
            case .success(let lesson):
                self.title = lesson.title
                self.descriptionText = lesson.desc
                self.contentText = lesson.content
                self.originalImageUrl = lesson.imageUrl
                self.originalUserId = lesson.userId
            case .failure(let error):
                onShowError("Failed to load lesson details: \(error.localizedDescription)")
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
        
        let userIdForUpdate: String?
        if let fetchedUserId = self.originalUserId {
            userIdForUpdate = fetchedUserId
        } else {
            // This logic might need refinement based on whether an admin is updating
            // someone else's lesson or if userId should always be the current admin.
            // For now, it mirrors the previous logic but without a token.
            userIdForUpdate = Auth.auth().currentUser?.uid
        }

        let updatedLesson = Lesson(
            id: lessonId,
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            imageUrl: originalImageUrl,
            userId: userIdForUpdate
        )
        
        // No token passed to VM method
        viewModel.updateExistingLesson(updatedLesson,
            onSuccess: {
                onLessonUpdated()
                viewModel.resetStatusFlags()
            },
            onError: { errorMessage in
                onShowError(errorMessage)
            }
        )
    }
}

struct AdminUpdateLessonView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure Firebase is configured for the preview
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return AdminUpdateLessonView(
            lessonId: "previewLesson123",
            onLessonUpdated: { print("Preview: Lesson Updated") },
            onShowError: { error in print("Preview: Error - \(error)") }
        )
        .environmentObject(AdminUpdateLessonViewModel())
    }
}
