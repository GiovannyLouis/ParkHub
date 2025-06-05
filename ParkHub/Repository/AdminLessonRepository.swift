//
//  AdminLessonRepository.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 04/06/25.
//


import FirebaseDatabase
import FirebaseAuth
import Foundation

class AdminLessonRepository {
    private var ref: DatabaseReference = Database.database().reference().child("lessons")
    private var lessonsHandle: DatabaseHandle?
    
    // MARK: - Fetch all lessons
    func fetchAllLessons(completion: @escaping (Result<[Lesson], Error>) -> Void) {
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
        }
        
        lessonsHandle = ref.observe(.value) { snapshot in
            if !snapshot.exists() {
                completion(.success([]))
                return
            }
            
            var lessons: [Lesson] = []
            for child in snapshot.children {
                if let lessonSnapshot = child as? DataSnapshot,
                   let dict = lessonSnapshot.value as? [String: Any] {
                    let lesson = Lesson(
                        id: lessonSnapshot.key,
                        title: dict["title"] as? String ?? "",
                        desc: dict["desc"] as? String ?? "",
                        content: dict["content"] as? String ?? "",
                        userId: dict["userId"] as? String
                    )
                    lessons.append(lesson)
                }
            }
            completion(.success(lessons))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    func stopListeningForLessons() {
        if let handle = lessonsHandle {
            ref.removeObserver(withHandle: handle)
            lessonsHandle = nil
        }
    }
    
    // MARK: - Save new lesson
    func saveNewLesson(_ lesson: Lesson, completion: @escaping (Result<Void, Error>) -> Void) {
        let newLessonRef = ref.childByAutoId()
        var lessonToSave = lesson
        lessonToSave.id = newLessonRef.key ?? UUID().uuidString
        
        guard let jsonData = try? JSONEncoder().encode(lessonToSave),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode lesson"])))
            return
        }
        
        newLessonRef.setValue(json) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchLessonDetails(lessonId: String) async -> Result<Lesson, Error> {
            do {
                // Using Firebase's async/await API (requires Firebase SDK version that supports it, e.g., Firebase 9+ for Swift)
                let snapshot = try await ref.child(lessonId).getData() // .getData() is async

                guard snapshot.exists(),
                      let dict = snapshot.value as? [String: Any] else {
                    return .failure(NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lesson not found."]))
                }

                let lesson = Lesson(
                    id: snapshot.key,
                    title: dict["title"] as? String ?? "",
                    desc: dict["desc"] as? String ?? "",
                    content: dict["content"] as? String ?? "",
                    userId: dict["userId"] as? String
                )
                return .success(lesson)
            } catch {
                return .failure(error) // Propagate the error from Firebase
            }
        }
    
    
    // MARK: - Update lesson
    func updateLesson(_ lesson: Lesson, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(lesson),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            completion(.failure(NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode lesson"])))
            return
        }
        
        ref.child(lesson.id).setValue(json) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Delete lesson
    func deleteLesson(lessonId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        ref.child(lessonId).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
