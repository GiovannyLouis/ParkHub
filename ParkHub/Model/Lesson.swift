// Lesson.swift
import Foundation

struct Lesson: Identifiable {
    var id: String { lessonId }
    var lessonId: String = ""
    var title: String = ""
    var desc: String = ""
    var content: String = ""
    var imageUrl: String = ""
}
