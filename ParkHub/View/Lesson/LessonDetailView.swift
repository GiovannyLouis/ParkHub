// File: LessonDetailView.swift
// ParkHub

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    LogoSmall()

                    Spacer()

                    Button(action: {
                        print("Logout tapped from LessonDetail")
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

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Button(action: {
                            dismiss()
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
        .navigationBarHidden(true)
    }
}

#Preview {
    LessonDetailView(
        lesson: Lesson(
            id: "detail_prev_1",
            title: "Advanced SwiftUI Techniques",
            desc: "A deep dive into advanced concepts.",
            content: "Sample content for preview..."
        )
    )
}
