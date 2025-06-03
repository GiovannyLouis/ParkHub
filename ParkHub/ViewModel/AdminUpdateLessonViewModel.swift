//
//  is.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


import FirebaseDatabase
import FirebaseAuth
import Foundation

// Assuming Lesson struct is defined elsewhere
// struct Lesson: Identifiable, Hashable, Codable { ... }

class AdminUpdateLessonViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var updateError: String? = nil
    @Published var updateSuccess: Bool = false

    private var ref: DatabaseReference!

    init() {
        self.ref = Database.database().reference().child("lessons")
    }

    // No token parameter needed here
    func fetchLessonDetails(lessonId: String, completion: @escaping (Result<Lesson, Error>) -> Void) {
        ref.child(lessonId).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let dict = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lesson not found."])))
                return
            }

            let lesson = Lesson(
                id: snapshot.key,
                title: dict["title"] as? String ?? "",
                desc: dict["desc"] as? String ?? "",
                content: dict["content"] as? String ?? "",
                imageUrl: dict["imageUrl"] as? String,
                userId: dict["userId"] as? String
            )
            completion(.success(lesson))
        } withCancel: { error in
            completion(.failure(error))
        }
    }

    // No token parameter needed here
    func updateExistingLesson(_ lesson: Lesson, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        isLoading = true
        updateError = nil
        updateSuccess = false

        // User check - ensure an admin or authorized user is performing this
        // This might involve checking Auth.auth().currentUser?.uid against an admin list
        // or relying on Firebase rules. For simplicity, we assume authorization is handled.
        guard Auth.auth().currentUser != nil else {
            updateError = "User not authenticated to perform this action."
            isLoading = false
            onError(updateError!)
            return
        }

        if lesson.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lesson.desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lesson.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updateError = "Title, Description, and Content cannot be empty."
            isLoading = false
            onError(updateError!)
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(lesson),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            updateError = "Failed to prepare lesson data for saving."
            isLoading = false
            onError(updateError!)
            return
        }
        
        ref.child(lesson.id).setValue(json) { [weak self] error, _ in
            guard let self = self else { return }
            
            self.isLoading = false
            if let error = error {
                self.updateError = "Failed to update lesson: \(error.localizedDescription)"
                self.updateSuccess = false
                onError(self.updateError!)
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
