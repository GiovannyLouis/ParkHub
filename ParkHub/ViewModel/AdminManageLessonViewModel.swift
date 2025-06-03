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

class AdminManageLessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading: Bool = false     // For fetch operation
    @Published var errorMessage: String? = nil // For fetch operation

    private var ref: DatabaseReference!
    private var lessonsHandle: DatabaseHandle? // Specific handle for lessons

    init() {
        // Ensure FirebaseApp.configure() is called once elsewhere in your app
        self.ref = Database.database().reference().child("lessons")
    }

    deinit {
        // Clean up the observer when the ViewModel is deallocated
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
        }
    }

    func fetchAllLessons(token: String) {
        isLoading = true
        errorMessage = nil

        // Remove previous listener to avoid multiple observers if called again
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
        }

        // For an admin view, you might want to fetch ALL lessons,
        // not just those by the current admin's userId.
        // If lessons are globally accessible to admins, you'd observe `ref` directly.
        // If admins only see lessons they created, then filter by userId.
        // The FoodSpotViewModel example filters by userId, so let's mirror that structure
        // for "exact style" but acknowledge this might change for admin roles.

        // Option A: Fetch ALL lessons (more typical for admin)
        lessonsHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.parseLessonsSnapshot(snapshot)
            self.isLoading = false
        }

        // Option B: Fetch lessons by current admin's userId (if admin also creates lessons under their ID)
        /*
        guard let adminUserId = Auth.auth().currentUser?.uid else {
            self.lessons = []
            self.errorMessage = "Admin user not authenticated."
            self.isLoading = false
            return
        }
        lessonsHandle = ref.queryOrdered(byChild: "userId") // Assuming 'userId' is the creator's ID
                           .queryEqual(toValue: adminUserId)
                           .observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.parseLessonsSnapshot(snapshot)
            self.isLoading = false
        }
        */
        // If the above .observe call encounters an error immediately (e.g. permission denied),
        // it might not set isLoading to false. Consider adding an error handler to the observe call if possible,
        // or a timeout mechanism if Firebase SDK supports it for .observe.
        // For simplicity, Firebase's .observe typically handles errors by logging them or returning an empty snapshot.
    }

    private func parseLessonsSnapshot(_ snapshot: DataSnapshot) {
        var fetchedLessons: [Lesson] = []
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
               let dict = snapshot.value as? [String: Any] {
                // Manually create Lesson from dictionary, ensuring all fields are handled
                let lesson = Lesson(
                    id: snapshot.key, // Firebase key is the ID
                    title: dict["title"] as? String ?? "",
                    desc: dict["desc"] as? String ?? "", // 'desc' from your Lesson model
                    content: dict["content"] as? String ?? "",
                    imageUrl: dict["imageUrl"] as? String, // Optional
                    userId: dict["userId"] as? String      // Optional, creator's ID
                )
                fetchedLessons.append(lesson)
            }
        }
        self.lessons = fetchedLessons
        if fetchedLessons.isEmpty && !self.isLoading { // Check isLoading to avoid overriding initial loading message
             // If you want a specific message for "no lessons found" vs. "error"
             // self.errorMessage = "No lessons found." // This might conflict with network error messages
        }
    }

    func deleteLesson(token: String, lessonId: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        ref.child(lessonId).removeValue { error, _ in
            if let error = error {
                onError("Failed to delete lesson: \(error.localizedDescription)")
            } else {
                onSuccess()
                // The real-time observer in fetchAllLessons should automatically update the `lessons` list.
                // No need to manually remove from the local array if using .observe(.value).
            }
        }
    }

    // Optional: If you want to stop listening explicitly, e.g., when view disappears
    func stopListeningForLessons() {
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
            lessonsHandle = nil
        }
    }
}
