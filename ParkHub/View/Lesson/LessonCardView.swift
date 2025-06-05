// File: LessonCardView.swift
// ParkHub

import SwiftUI

struct LessonCardView: View {
    let lesson: Lesson

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

            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                Text("Learn")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(primaryOrange)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        LessonCardView(
            lesson: Lesson(
                id: "preview1",
                title: "Sample Lesson Title",
                desc: "This is a sample description for the lesson card.",
                content: "Full content..."
            )
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
