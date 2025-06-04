// File: AdminUpdateLessonViewModel.swift

import FirebaseDatabase
import FirebaseAuth
import Foundation

// Assuming Lesson struct is defined elsewhere and does NOT include imageUrl

class AdminUpdateLessonViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var updateError: String? = nil
    @Published var updateSuccess: Bool = false // To notify the view of success

    private var ref: DatabaseReference!

    init() {
        // if FirebaseApp.app() == nil { FirebaseApp.configure() }
        self.ref = Database.database().reference().child("lessons") // Or your specific Firebase path
    }

    func fetchLessonDetails(lessonId: String, completion: @escaping (Result<Lesson, Error>) -> Void) {
        isLoading = true // Indicate loading started
        updateError = nil
        
        ref.child(lessonId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false // Loading finished

            guard snapshot.exists(), let dict = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lesson not found."])))
                return
            }

            // Create Lesson object without imageUrl
            let lesson = Lesson(
                id: snapshot.key,
                title: dict["title"] as? String ?? "",
                desc: dict["desc"] as? String ?? "",
                content: dict["content"] as? String ?? "",
                // imageUrl removed
                userId: dict["userId"] as? String
            )
            completion(.success(lesson))
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false // Loading finished
            completion(.failure(error))
        }
    }

    func updateExistingLesson(_ lesson: Lesson, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        isLoading = true
        updateError = nil
        updateSuccess = false

        guard Auth.auth().currentUser != nil else {
            let errorMsg = "User not authenticated to perform this action."
            self.updateError = errorMsg
            self.isLoading = false
            onError(errorMsg)
            return
        }

        if lesson.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lesson.desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lesson.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let errorMsg = "Title, Description, and Content cannot be empty."
            self.updateError = errorMsg
            self.isLoading = false
            onError(errorMsg)
            return
        }
        
        // JSONEncoder will correctly encode the Lesson struct (which no longer has imageUrl)
        guard let jsonData = try? JSONEncoder().encode(lesson),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            let errorMsg = "Failed to prepare lesson data for saving."
            self.updateError = errorMsg
            self.isLoading = false
            onError(errorMsg)
            return
        }
        
        ref.child(lesson.id).setValue(json) { [weak self] error, _ in
            guard let self = self else { return }
            
            self.isLoading = false
            if let error = error {
                let errorMsg = "Failed to update lesson: \(error.localizedDescription)"
                self.updateError = errorMsg
                self.updateSuccess = false
                onError(errorMsg)
            } else {
                self.updateSuccess = true
                onSuccess()
            }
        }
    }
    
    func resetStatusFlags() {
        updateSuccess = false
        updateError = nil
    }
}
