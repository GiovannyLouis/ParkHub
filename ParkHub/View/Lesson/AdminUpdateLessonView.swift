// File: AdminUpdateLessonView.swift

import SwiftUI
import FirebaseAuth

struct AdminUpdateLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var viewModel: AdminLessonViewModel
    @Environment(\.dismiss) var dismiss

    // State for UI fields
    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""
    
    // State for loading and lesson data
    @State private var isFetchingDetails: Bool = true

    let lessonId: String
    var onLessonUpdated: () -> Void
    var onShowError: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ScrollView {
                if isFetchingDetails {
                    ProgressView("Loading lesson details...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange)) // Assuming primaryOrange
                        .padding(.top, 50)
                } else {
                    // The rest of your form UI...
                    VStack(alignment: .leading, spacing: 16) {
                        // Back Button
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17))
                            }
                        }
                        .foregroundColor(.orange) // Assuming primaryOrange
                        .padding(.bottom, 10)

                        Text("Update Lesson")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 5)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("Lesson ID: \(lessonId)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)

                        // Form Fields
                        Group {
                            Text("Title:").font(.headline)
                            TextField("Enter new title (optional)", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)

                            Text("Description:").font(.headline)
                            TextField("Enter new description (optional)", text: $descriptionText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)

                            Text("Content:").font(.headline)
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

                        // Update Button
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
                        .background(Color.orange) // Assuming primaryOrange
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading || allFieldsAreEmpty)
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear(perform: loadLessonDetails) // This will now work correctly
            .navigationBarHidden(true)

            BotAppBar()
        }
        .navigationBarHidden(true)
    }
    
    private var allFieldsAreEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadLessonDetails() {
        // MODIFICATION: Add a guard to prevent fetching with an invalid ID.
        guard !lessonId.isEmpty else {
            isFetchingDetails = false
            onShowError("An invalid lesson ID was provided.")
            dismiss()
            return
        }
        
        isFetchingDetails = true
        Task {
            let result = await viewModel.fetchLessonDetails(lessonId: lessonId)
            await MainActor.run {
                isFetchingDetails = false
                switch result {
                case .success(let lesson):
                    // Pre-fill the fields with existing data
                    self.title = lesson.title
                    self.descriptionText = lesson.desc
                    self.contentText = lesson.content
                case .failure(let error):
                    onShowError("Failed to load lesson details: \(error.localizedDescription)")
                    dismiss()
                }
            }
        }
    }

    private func attemptUpdateLesson() {
        viewModel.updateExistingLesson(
            lessonId: lessonId,
            title: title,
            desc: descriptionText,
            content: contentText,
            onSuccess: {
                onLessonUpdated()
                viewModel.resetUpdateStatusFlags()
                // No need to dismiss here, the parent view's binding will handle it.
            },
            onError: { errorMessage in
                onShowError(errorMessage)
            }
        )
    }
}
#Preview {

    NavigationView {
        AdminUpdateLessonView(
            lessonId: "previewLesson123",
            onLessonUpdated: { print("Preview: Lesson updated!") },
            onShowError: { error in print("Preview Error: \(error)") }
        )
        .environmentObject(AuthViewModel())
        .environmentObject(AdminLessonViewModel())
    }
}
