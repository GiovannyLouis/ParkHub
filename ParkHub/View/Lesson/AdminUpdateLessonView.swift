// File: AdminUpdateLessonView.swift

import SwiftUI
import FirebaseAuth

struct AdminUpdateLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var viewModel: AdminLessonViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""
    @State private var originalUserId: String? = nil

    @State private var isFetchingDetails: Bool = false

    let lessonId: String
    var onLessonUpdated: () -> Void
    var onShowError: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ScrollView {
                if isFetchingDetails {
                    ProgressView("Loading lesson details...")
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                        .padding(.top, 50)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17))
                            }
                        }
                        .foregroundColor(primaryOrange)
                        .padding(.bottom, 10)

                        Text("Update Lesson")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.bottom, 5)
                            .frame(maxWidth: .infinity, alignment: .center)

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
                        .disabled(viewModel.isLoading ||
                                  title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                  descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                  contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))

            BotAppBar()
        }
        .task(id: lessonId) { // Automatically cancels if the view disappears or lessonId changes
            await loadLessonDetails()
        }
//        .onAppear(perform: loadLessonDetailsAsync())
        .navigationBarHidden(true)
    }
    
    private func loadLessonDetails() async {
            print("AdminUpdateLessonView - loadLessonDetailsAsync called with lessonId: '\(lessonId)'")
            guard !Task.isCancelled else {
                print("AdminUpdateLessonView - Task cancelled before starting fetch.")
                return
            }

            isFetchingDetails = true
            let result = await viewModel.fetchLessonDetails(lessonId: lessonId)

            guard !Task.isCancelled else {
                print("AdminUpdateLessonView - Task cancelled during fetch.")
                isFetchingDetails = false
                return
            }

            isFetchingDetails = false
            switch result {
            case .success(let lesson):
                print("AdminUpdateLessonView - Successfully fetched lesson: \(lesson.title)")
                title = lesson.title
                descriptionText = lesson.desc
                contentText = lesson.content
                originalUserId = lesson.userId
            case .failure(let error):
                print("AdminUpdateLessonView - Failed to fetch lesson: \(error.localizedDescription)")
                onShowError("Failed to load lesson details: \(error.localizedDescription)")
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

        let userIdForUpdate = originalUserId ?? Auth.auth().currentUser?.uid

        let updatedLesson = Lesson(
            id: lessonId,
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            userId: userIdForUpdate
        )

        viewModel.updateExistingLesson(updatedLesson,
            onSuccess: {
                onLessonUpdated()
                viewModel.resetUpdateStatusFlags()
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
