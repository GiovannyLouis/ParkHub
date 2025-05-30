//
//  LessonCardView.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 30/05/25.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
let logoutRed = Color(hex: 0xFFD9534F)
let primaryOrange = Color(hex: 0xffffa001)

struct LessonCardView: View {
    let lesson: Lesson
    var onLessonClick: (Lesson) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lesson.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            Spacer().frame(height: 8)

            Text(lesson.desc)
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Spacer().frame(height: 16)

            Button(action: {
                onLessonClick(lesson)
            }) {
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
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
}

struct LessonCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLesson = Lesson(
            lessonId: "preview1",
            title: "Sample Lesson Title",
            desc: "This is a sample description for the lesson card to see how it looks in preview.",
            content: "Full content...",
            imageUrl: "swiftui_logo"
        )
        LessonCardView(lesson: sampleLesson) { lesson in
            print("Learn button tapped for: \(lesson.title)")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
