//
//  LessonRepository.swift
//  ParkHub
//
//  Created by Axel Valerio Ertamto on 04/06/25.
//


import FirebaseDatabase

class LessonRepository {
    private var dbRef = Database.database().reference().child("lessons")
    private var lessonsHandle: DatabaseHandle?

    func observeLessons(onUpdate: @escaping ([Lesson]) -> Void, onError: @escaping (Error) -> Void) {
        if let handle = lessonsHandle {
            dbRef.removeObserver(withHandle: handle)
            lessonsHandle = nil
        }
        lessonsHandle = dbRef.observe(.value) { snapshot in
            var fetchedLessons: [Lesson] = []
            if !snapshot.exists() {
                onUpdate([])
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
            onUpdate(fetchedLessons)
        } withCancel: { error in
            onError(error)
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
}
