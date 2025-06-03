import SwiftUI

// Assuming Lesson struct and Color extension are defined elsewhere or in this file scope for preview
// struct Lesson: Identifiable, Hashable, Codable { ... }
// extension Color { ... }
// let primaryOrange = Color(hex: 0xffffa001)

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
                .lineLimit(3) // Added to prevent overly long descriptions

            Spacer().frame(height: 16)

            Button(action: {
                onLessonClick(lesson)
            }) {
                Text("Learn")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(primaryOrange) // Assuming primaryOrange is defined
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1) // Softened border
        )
        .padding(.vertical, 8)
    }
}

struct LessonCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure Lesson struct, Color extension, and primaryOrange are available in this scope for preview
        // For standalone preview, you might need to paste them here or ensure they are globally accessible.
        
        // Sample Lesson model for preview
        /*
        struct Lesson: Identifiable, Hashable, Codable {
            var id: String = UUID().uuidString
            var title: String
            var desc: String
            var content: String
            var imageUrl: String?
            var userId: String?
        }
        
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
        let primaryOrange = Color(hex: 0xffffa001)
        */

        let sampleLesson = Lesson(
            id: "preview1", // Corrected: used 'id' instead of 'lessonId'
            title: "Sample Lesson Title",
            desc: "This is a sample description for the lesson card to see how it looks in preview. It can be a bit longer to test text wrapping.",
            content: "Full content of the sample lesson goes here...", // Added required 'content' field
            imageUrl: "swiftui_logo" // Assuming "swiftui_logo" is an asset in your project
        )
        
        LessonCardView(lesson: sampleLesson) { lesson in
            print("Learn button tapped for: \(lesson.title)")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
