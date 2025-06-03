import SwiftUI
import FirebaseDatabase
import FirebaseAuth

class LessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var dbRef: DatabaseReference!
    private var lessonsHandle: DatabaseHandle?

    init() {
        self.dbRef = Database.database().reference().child("lessons_codable_rtdb")
    }

    func fetchAllLessons(token: String) {
        isLoading = true
        errorMessage = nil

        if let handle = lessonsHandle {
            dbRef.removeObserver(withHandle: handle)
        }

        lessonsHandle = dbRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            var fetchedLessons: [Lesson] = []

            if !snapshot.exists() {
                self.errorMessage = "No lessons found."
                self.lessons = []
                return
            }

            for child in snapshot.children {
                if let lessonSnapshot = child as? DataSnapshot,
                   let value = lessonSnapshot.value {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        var lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
                        lesson.id = lessonSnapshot.key
                        fetchedLessons.append(lesson)
                    } catch {
                        print("Decoding error for lesson ID \(lessonSnapshot.key): \(error)")
                    }
                }
            }
            self.lessons = fetchedLessons
            if fetchedLessons.isEmpty && self.errorMessage == nil {
                 self.errorMessage = "No valid lesson data could be parsed."
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
            self.lessons = []
        }
    }
    
    func removeObservers() {
        if let handle = lessonsHandle {
            dbRef.removeObserver(withHandle: handle)
            lessonsHandle = nil
        }
    }

    deinit {
        removeObservers()
    }

    func fetchMockLessons() {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.lessons = [
                Lesson(title: "Mock SwiftUI Codable", desc: "Lesson using Codable.", content: "Content...", imageUrl: "swiftui_logo"),
                Lesson(title: "Mock State Codable", desc: "Another Codable lesson.", content: "More content...", imageUrl: "state_icon")
            ]
            self.isLoading = false
        }
    }
}
