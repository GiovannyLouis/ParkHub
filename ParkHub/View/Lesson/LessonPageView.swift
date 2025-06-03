import SwiftUI

// Assuming Lesson, LogoSmall, BotAppBar, primaryOrange, logoutRed are defined
// struct Lesson: Identifiable, Hashable, Codable { ... }
// struct LogoSmall: View { ... }
// struct BotAppBar: View { ... }
// extension Color { ... }
// let primaryOrange = Color(hex: 0xffffa001)
// let logoutRed = Color(hex: 0xFFD9534F)

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

// Assuming Lesson struct, TopAppBar, BotAppBar, primaryOrange are defined
// struct Lesson: Identifiable, Hashable, Codable { ... }
// struct TopAppBar: View { ... }
// struct BotAppBar: View { ... }
// let primaryOrange = Color(hex: 0xffffa001)

struct LessonPageView: View {
    // Sample data now correctly initializes Lesson objects
    let lessons: [Lesson] = [
        Lesson(id: "s1", title: "Masterclass to SwiftUI", desc: "Learn the fundamentals of building UIs with SwiftUI.", content: "Detailed content for SwiftUI Masterclass...", imageUrl: "swiftui_logo"),
        Lesson(id: "s1_alt", title: "Introduction to SwiftUI", desc: "Learn the fundamentals of building UIs with SwiftUI.", content: "Detailed content for Introduction to SwiftUI...", imageUrl: "swiftui_logo"),
        Lesson(id: "s2", title: "State Management", desc: "Understand how state and data flow work in SwiftUI applications.", content: "Detailed content for State Management...", imageUrl: "state_icon"),
        Lesson(id: "s3", title: "Navigation in SwiftUI", desc: "Explore different ways to navigate between views.", content: "Detailed content for Navigation in SwiftUI...", imageUrl: "navigation_icon"),
        Lesson(id: "s4", title: "Working with Lists", desc: "Deep dive into creating dynamic lists and grids.", content: "Detailed content for Working with Lists...", imageUrl: "list_icon")
    ]
    
    @State var isLoading: Bool = false // Made @State for dynamic changes, if needed
    @State var errorMessage: String? = nil // Made @State for dynamic changes, if needed
    
    var token: String // Assuming this is passed in
    var onLessonClick: (Lesson) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TopAppBar() // Assuming TopAppBar is defined
            
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryOrange)) // Assuming primaryOrange is defined
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
                                .listRowInsets(EdgeInsets()) // Removes default padding
                                .padding(.horizontal, 16) // Apply consistent horizontal padding
                                .padding(.bottom, 8) // Add some space between cards
                        }
                    }
                    .listStyle(PlainListStyle()) // Removes default List styling
                }
            }
            
            BotAppBar() // Assuming BotAppBar is defined
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        // .onAppear {
        //     // Example: fetch lessons or set loading state
        // }
    }
}

struct LessonPageView_Previews: PreviewProvider {
    static var previews: some View {
        // For preview, ensure dependent structs/vars are available or stubbed
        // struct Lesson: Identifiable, Hashable, Codable { ... }
        // struct TopAppBar: View { var body: some View { Text("Top App Bar") } }
        // struct BotAppBar: View { var body: some View { Text("Bot App Bar") } }
        // extension Color { init(hex: UInt, alpha: Double = 1) { ... } }
        // let primaryOrange = Color(hex: 0xffffa001)
        
        LessonPageView(
            token: "dummy_token_for_preview",
            onLessonClick: { lesson in
                print("Lesson tapped in preview: \(lesson.title)")
            }
        )
    }
}
