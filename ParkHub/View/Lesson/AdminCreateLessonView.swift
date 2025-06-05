// File: AdminCreateLessonView.swift
// ParkHub

import SwiftUI
import FirebaseAuth

struct AdminCreateLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var viewModel: AdminLessonViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var contentText: String = ""

    var onLessonCreated: () -> Void
    var onShowError: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                    }
                    .foregroundColor(primaryOrange)
                    .padding(.bottom, 10)

                    Text("Create Lesson")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, alignment: .center)

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
                                .frame(height: 24)
                        } else {
                            Text("Create")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(primaryOrange)
                    .cornerRadius(8)
                    .disabled(
                        viewModel.isLoading ||
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))

            BotAppBar()
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.creationSuccess) { success in
            if success {
                onLessonCreated()
                resetFormFields()
                viewModel.resetCreationStatusFlags()
            }
        }
        .onChange(of: viewModel.creationError) { error in
            if let err = error, !err.isEmpty {
                onShowError(err)
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
            id: "",
            title: trimmedTitle,
            desc: trimmedDescription,
            content: trimmedContent,
            userId: userId
        )

        viewModel.saveNewLesson(newLesson)
    }

    private func resetFormFields() {
        title = ""
        descriptionText = ""
        contentText = ""
    }
}

#Preview {

    NavigationView {
        AdminCreateLessonView(
            onLessonCreated: { print("Preview: Lesson created!") },
            onShowError: { error in print("Preview Error: \(error)") }
        )
        .environmentObject(AuthViewModel())
        .environmentObject(AdminLessonViewModel())
    }
}

