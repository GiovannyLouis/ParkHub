// File: LessonCardView.swift
// ParkHub

import SwiftUI

// Assuming Lesson struct and primaryOrange are defined

struct LessonCardView: View {
    let lesson: Lesson
    // var onLessonClick: (Lesson) -> Void // REMOVED

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lesson.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            Spacer().frame(height: 8)

            Text(lesson.desc)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineLimit(3)

            Spacer().frame(height: 16)

            // MODIFIED: Button becomes a NavigationLink
            NavigationLink(destination: LessonDetailView(lesson: lesson)) { // Pass only lesson
                Text("Learn")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(primaryOrange)
                    .cornerRadius(8)
            }
            // To make the NavigationLink look like your button,
            // ensure its label (the Text view) has the styling.
            // If NavigationLink adds its own styling (like blue text or disclosure indicator),
            // you might need .buttonStyle(PlainButtonStyle()) on the NavigationLink
            // or ensure the Label fills the space and styles itself.
            // For this common setup, the current styling on Text should work well.

        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .padding(.vertical, 8) // This padding might be better on the List's row in LessonPageView
    }
}

#Preview {
    NavigationView { // Wrap in NavigationView for NavigationLink to work in preview
        LessonCardView(
            lesson: Lesson(
                id: "preview1",
                title: "Sample Lesson Title",
                desc: "This is a sample description for the lesson card.",
                content: "Full content..."
            )
            // onLessonClick: { _ in } // No longer needed
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
