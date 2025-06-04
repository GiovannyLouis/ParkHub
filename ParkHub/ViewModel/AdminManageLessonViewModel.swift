// File: AdminManageLessonViewModel.swift

import FirebaseDatabase
import FirebaseAuth
import Foundation


class AdminManageLessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var ref: DatabaseReference!
    private var lessonsHandle: DatabaseHandle?

    init() {
        // Ensure FirebaseApp.configure() is called once, typically in your App's init or AppDelegate.
        // if FirebaseApp.app() == nil { FirebaseApp.configure() }
        self.ref = Database.database().reference().child("lessons") // Or your specific Firebase path
    }

    deinit {
        stopListeningForLessons()
    }

    func fetchAllLessons(token: String) { // Token might be for other API calls or future use
        isLoading = true
        errorMessage = nil

        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
        }

        // Fetching all lessons, typical for an admin view.
        lessonsHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false // Set loading to false once data (or lack thereof) is received
            self.parseLessonsSnapshot(snapshot)
        } withCancel: { [weak self] error in // Handle cancellation or permission errors
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
            self.lessons = []
        }
    }

    private func parseLessonsSnapshot(_ snapshot: DataSnapshot) {
        var fetchedLessons: [Lesson] = []
        if !snapshot.exists() {
            self.lessons = []
            // Optionally set a message if no data is different from an error
            // self.errorMessage = "No lessons found."
            return
        }
        
        for child in snapshot.children {
            if let lessonSnapshot = child as? DataSnapshot, // Renamed for clarity
               let dict = lessonSnapshot.value as? [String: Any] {
                // Manually create Lesson from dictionary
                let lesson = Lesson(
                    id: lessonSnapshot.key, // Firebase key is the ID
                    title: dict["title"] as? String ?? "",
                    desc: dict["desc"] as? String ?? "",
                    content: dict["content"] as? String ?? "",
                    // imageUrl removed
                    userId: dict["userId"] as? String
                )
                fetchedLessons.append(lesson)
            }
        }
        self.lessons = fetchedLessons
        if fetchedLessons.isEmpty && self.errorMessage == nil { // If snapshot existed but no valid lessons parsed
            // self.errorMessage = "No valid lesson data could be parsed."
        }
    }

    func deleteLesson(token: String, lessonId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        ref.child(lessonId).removeValue { error, _ in
            if let error = error {
                onError("Failed to delete lesson: \(error.localizedDescription)")
            } else {
                onSuccess()
                // Real-time observer in fetchAllLessons will update the list.
            }
        }
    }

    func stopListeningForLessons() {
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
            lessonsHandle = nil
        }
    }
}
