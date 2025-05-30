// LessonPageView.swift
import SwiftUI

struct LessonPageView: View {
    let lessons: [Lesson] = [
        Lesson(lessonId: "s1", title: "Masterclass to SwiftUI", desc: "Learn the fundamentals of building UIs with SwiftUI.", imageUrl: "swiftui_logo"),
        Lesson(lessonId: "s1_alt", title: "Introduction to SwiftUI", desc: "Learn the fundamentals of building UIs with SwiftUI.", imageUrl: "swiftui_logo"),
        Lesson(lessonId: "s2", title: "State Management", desc: "Understand how state and data flow work in SwiftUI applications.", imageUrl: "state_icon"),
        Lesson(lessonId: "s3", title: "Navigation in SwiftUI", desc: "Explore different ways to navigate between views.", imageUrl: "navigation_icon"),
        Lesson(lessonId: "s4", title: "Working with Lists", desc: "Deep dive into creating dynamic lists and grids.", imageUrl: "list_icon")
    ]

    let isLoading: Bool = false
    let errorMessage: String? = nil

    var token: String
    var onLessonClick: (Lesson) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TopAppBar()

            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange))
                    .scaleEffect(1.5)
                Spacer()
            } else if let message = errorMessage {
                Spacer()
                Text(message)
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                if lessons.isEmpty {
                    Spacer()
                    Text("No lessons available at the moment.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(lessons) { lesson in
                            LessonCardView(lesson: lesson, onLessonClick: onLessonClick)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal, 16)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }

            BotAppBar()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct LessonPageView_Previews: PreviewProvider {
    static var previews: some View {
        LessonPageView(
            token: "dummy_token_for_preview",
            onLessonClick: { lesson in
                print("Lesson tapped in preview: \(lesson.title)")
            }
        )
    }
}
