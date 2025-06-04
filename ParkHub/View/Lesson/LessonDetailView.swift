// File: LessonDetailView.swift
// ParkHub

import SwiftUI

// Assuming Lesson, LogoSmall, BotAppBar, primaryOrange, logoutRed are defined
// (as they were in your provided code)

struct LessonDetailView: View {
    let lesson: Lesson
    // var onBackClick: () -> Void // REMOVED: Replaced by @Environment(\.dismiss)

    @Environment(\.dismiss) var dismiss // ADDED: For programmatic dismissal

    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar
            VStack {
                HStack {
                    LogoSmall()

                    Spacer()

                    Button(action: {
                        print("Logout tapped from LessonDetail")
                        // Implement actual logout logic here (e.g., using AuthViewModel)
                    }) {
                        Text("Logout")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(logoutRed)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 + 20)
            }
            .frame(maxWidth: .infinity)
            .background(primaryOrange)
            .edgesIgnoringSafeArea(.top)

            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Back button and Title
                    HStack(spacing: 8) {
                        Button(action: {
                            dismiss() // MODIFIED: Use dismiss action
                        }) {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        Text(lesson.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }

                    // Lesson Content
                    Text(lesson.content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)

            BotAppBar()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true) // This remains, as it has a custom top bar
    }
}

#Preview {
    // Preview now doesn't need onBackClick
    LessonDetailView(
        lesson: Lesson(
            id: "detail_prev_1",
            title: "Advanced SwiftUI Techniques",
            desc: "A deep dive into advanced concepts.",
            content: "Sample content for preview..."
        )
        // onBackClick: { } // No longer needed
    )
}
