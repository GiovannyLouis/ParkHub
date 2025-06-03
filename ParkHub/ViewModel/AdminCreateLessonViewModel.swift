//
//  AdminCreateLessonViewModel.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 03/06/25.
//


// AdminCreateLessonViewModel.swift
import FirebaseDatabase
import FirebaseAuth
import Foundation

class AdminCreateLessonViewModel: ObservableObject {
    // MARK: - Published Properties for UI State (these remain)
    @Published var isLoading: Bool = false
    @Published var creationError: String? = nil
    @Published var creationSuccess: Bool = false

    // MARK: - Firebase Properties
    private var ref: DatabaseReference!

    // MARK: - Initializer
    init() {
        self.ref = Database.database().reference().child("lessons")
    }

    // MARK: - Public Methods
    func saveNewLesson(_ lesson: Lesson, token: String) { // Accepts a Lesson object
        isLoading = true
        creationError = nil
        creationSuccess = false

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            creationError = "User not authenticated. Please sign in."
            isLoading = false
            return
        }

        // Ensure the lesson's userId is consistent or set it.
        // This example assumes the lesson object passed in has the correct userId
        // or it will be set if nil.
        var lessonToSave = lesson
        if lessonToSave.userId == nil {
            lessonToSave.userId = currentUserId
        } else if lessonToSave.userId != currentUserId {
            // Handle potential mismatch if necessary, e.g., admin creating for other users.
            // For simplicity here, we'll assume userId in lesson object is authoritative if set,
            // or defaults to current user. If strict matching is needed:
            // creationError = "User ID mismatch."
            // isLoading = false
            // return
        }

        // Basic Validation (can also be done in the view before calling this)
        if lessonToSave.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lessonToSave.desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           lessonToSave.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            creationError = "Title, Description, and Content cannot be empty."
            isLoading = false
            return
        }

        guard let jsonData = try? JSONEncoder().encode(lessonToSave),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            creationError = "Failed to prepare lesson data for saving."
            isLoading = false
            return
        }

        ref.child(lessonToSave.id).setValue(json) { [weak self] error, _ in
            guard let self = self else { return }
            
            self.isLoading = false
            if let error = error {
                self.creationError = "Failed to save lesson: \(error.localizedDescription)"
                self.creationSuccess = false
            } else {
                self.creationSuccess = true
                // ViewModel no longer resets input fields as it doesn't own them.
            }
        }
    }
    
    // Call this from the view if you want the VM to reset its success/error flags
    // after they've been handled by the view.
    func resetStatusFlags() {
        creationSuccess = false
        creationError = nil // Or set to nil when an operation starts
    }
}
