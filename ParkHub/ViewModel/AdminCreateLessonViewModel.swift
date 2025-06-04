// File: AdminCreateLessonViewModel.swift

import FirebaseDatabase
import FirebaseAuth
import Foundation

// Assuming Lesson struct is defined elsewhere and does NOT include imageUrl

class AdminCreateLessonViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var creationError: String? = nil
    @Published var creationSuccess: Bool = false

    private var ref: DatabaseReference!

    init() {
        // if FirebaseApp.app() == nil { FirebaseApp.configure() }
        self.ref = Database.database().reference().child("lessons") // Or your specific Firebase path
    }

    func saveNewLesson(_ lesson: Lesson, token: String) { // Lesson object no longer has imageUrl
        isLoading = true
        creationError = nil
        creationSuccess = false

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            creationError = "User not authenticated. Please sign in."
            isLoading = false
            return
        }

        var lessonToSave = lesson
        if lessonToSave.userId == nil {
            lessonToSave.userId = currentUserId
        }
        // If lessonToSave.userId is already set, it's preserved.

        if lessonToSave.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lessonToSave.desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lessonToSave.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            creationError = "Title, Description, and Content cannot be empty."
            isLoading = false
            return
        }

        // JSONEncoder will correctly encode the Lesson struct (which no longer has imageUrl)
        guard let jsonData = try? JSONEncoder().encode(lessonToSave),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            creationError = "Failed to prepare lesson data for saving."
            isLoading = false
            return
        }

        // If lesson.id is pre-set (e.g., by UUID() in struct), use it.
        // Otherwise, Firebase can generate a unique key with .childByAutoId()
        // For consistency with how you might fetch/update, using lesson.id is common.
        ref.child(lessonToSave.id).setValue(json) { [weak self] error, _ in
            guard let self = self else { return }
            
            self.isLoading = false
            if let error = error {
                self.creationError = "Failed to save lesson: \(error.localizedDescription)"
                self.creationSuccess = false
            } else {
                self.creationSuccess = true
            }
        }
    }
    
    func resetStatusFlags() {
        creationSuccess = false
        creationError = nil
    }
}
