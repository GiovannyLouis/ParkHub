// File: AdminManageLessonView.swift
// ParkHub

import SwiftUI

struct AlertInfo: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

struct AdminManageLessonView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var viewModel: AdminLessonViewModel
    @Environment(\.dismiss) var dismiss

    let token: String
    var onLogout: () -> Void

    @State private var lessonIdToUpdate: String? = nil
    @State private var alertInfo: AlertInfo?
    @State private var navigateToCreateLesson = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopAppBar()

                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.orange)
                        }
                        .padding([.leading, .top])
                        .padding(.bottom, 10)

                        contentView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                    .onAppear {
                        viewModel.fetchAllLessons()
                    }

                    NavigationLink(destination:
                        AdminCreateLessonView(
                            token: token,
                            onLessonCreated: {
                                alertInfo = AlertInfo(message: "Lesson created successfully!", isError: false)
                                viewModel.fetchAllLessons()
                            },
                            onShowError: { errorMessage in
                                alertInfo = AlertInfo(message: errorMessage, isError: true)
                            }
                        )
                        .environmentObject(authVM)
                        .environmentObject(viewModel),
                        isActive: $navigateToCreateLesson
                    ) {
                        EmptyView()
                    }

                    Button(action: {
                        navigateToCreateLesson = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }

                BotAppBar()
            }
            .navigationBarHidden(true)
            .alert(item: $alertInfo) { info in
                Alert(
                    title: Text(info.isError ? "Error" : "Success"),
                    message: Text(info.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { lessonIdToUpdate != nil },
                set: { isActive in
                    if !isActive { lessonIdToUpdate = nil }
                }
            )) {
                if let lessonId = lessonIdToUpdate {
                    AdminUpdateLessonView(
                        lessonId: lessonId,
                        onLessonUpdated: {
                            lessonIdToUpdate = nil
                            alertInfo = AlertInfo(message: "Lesson updated successfully!", isError: false)
                            viewModel.fetchAllLessons()
                        },
                        onShowError: { errorMessage in
                            alertInfo = AlertInfo(message: errorMessage, isError: true)
                        }
                    )
                    .environmentObject(authVM)
                    .environmentObject(viewModel)
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.lessons.isEmpty {
            Spacer()
            ProgressView("Loading lessons...")
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, alignment: .center)
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
                            lessonIdToUpdate = lesson.id
                        },
                        onDelete: {
                            viewModel.deleteLesson(
                                lessonId: lesson.id,
                                onSuccess: {
                                    alertInfo = AlertInfo(message: "Lesson deleted successfully!", isError: false)
                                },
                                onError: { errorMessage in
                                    alertInfo = AlertInfo(message: errorMessage, isError: true)
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
                viewModel.fetchAllLessons()
            }
        }
    }
}


struct AdminLessonCard: View {
    let lesson: Lesson
    var onUpdate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lesson.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            Text(lesson.desc)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineLimit(3)

            HStack(spacing: 10) {
                Button(action: onUpdate) {
                    Text("Update")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(primaryOrange)
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
                        .background(logoutRed)
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

#Preview {
    NavigationView {
        AdminManageLessonView(
            token: "preview_admin_token",
            onLogout: {
            }
        )
        .environmentObject(AuthViewModel())
        .environmentObject(AdminLessonViewModel())

    }
}
