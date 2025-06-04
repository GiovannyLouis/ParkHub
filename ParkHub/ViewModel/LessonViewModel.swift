import SwiftUI
import FirebaseDatabase
import FirebaseAuth // Keep if you use Auth for rules, even if token isn't directly in DB calls

class LessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var dbRef: DatabaseReference!
    private var lessonsHandle: DatabaseHandle?

    init() {
        // Ensure Firebase is configured. This is often done in AppDelegate or App struct.
        // if FirebaseApp.app() == nil { FirebaseApp.configure() }
        
        // ***** THIS IS THE KEY CHANGE *****
        // Point to the same database path as AdminManageLessonViewModel
        self.dbRef = Database.database().reference().child("lessons")
        // Previously: self.dbRef = Database.database().reference().child("lessons_codable_rtdb")
    }

    func fetchAllLessons(token: String) { // token might be userId, used for logging or if rules need it indirectly
        isLoading = true
        errorMessage = nil

        // Remove existing observer before adding a new one to prevent duplicates
        if let handle = lessonsHandle {
            dbRef.removeObserver(withHandle: handle)
            lessonsHandle = nil // Good practice to nil it out
        }

        lessonsHandle = dbRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            var fetchedLessons: [Lesson] = []

            if !snapshot.exists() {
                // self.errorMessage = "No lessons found." // Keep this or clear it, depending on desired UX
                self.lessons = []
                // If you want to show "No lessons available" in the UI, clearing errorMessage is better here.
                // The UI already handles empty lessons array.
                self.errorMessage = nil // Clear previous errors if snapshot exists but is empty
                return
            }
            
            self.errorMessage = nil // Clear any previous error message if we received data

            for child in snapshot.children {
                if let lessonSnapshot = child as? DataSnapshot,
                   let value = lessonSnapshot.value { // value is the dictionary [String: Any] for the lesson
                    do {
                        // Convert the Firebase dictionary to JSON Data
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        // Decode the Lesson struct from JSON Data
                        var lesson = try JSONDecoder().decode(Lesson.self, from: jsonData)
                        
                        // IMPORTANT: Override the ID with the Firebase key
                        // The Lesson struct's `id` field will have a default UUID,
                        // but we want the Firebase key to be the canonical ID.
                        lesson.id = lessonSnapshot.key
                        fetchedLessons.append(lesson)
                    } catch {
                        print("Decoding error for lesson ID \(lessonSnapshot.key): \(error)")
                        // Optionally, accumulate these errors or set a general parsing error message
                        // self.errorMessage = "Some lesson data could not be parsed."
                    }
                }
            }
            self.lessons = fetchedLessons
            
            // If snapshot existed, but all items failed to parse, or no children were present
            if fetchedLessons.isEmpty && snapshot.exists() && snapshot.hasChildren() {
                 self.errorMessage = "No valid lesson data could be parsed from the available records."
            } else if fetchedLessons.isEmpty && snapshot.exists() && !snapshot.hasChildren() {
                // Snapshot exists but has no children (e.g. "lessons": {} )
                // UI will show "No lessons available" due to empty lessons array.
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

    // Mock lessons can remain for testing UI independently of Firebase
    func fetchMockLessons() {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.lessons = [
                Lesson(title: "Mock SwiftUI Codable", desc: "Lesson using Codable.", content: "Content..."),
                Lesson(title: "Mock State Codable", desc: "Another Codable lesson.", content: "More content...")
            ]
            self.isLoading = false
        }
    }
}
