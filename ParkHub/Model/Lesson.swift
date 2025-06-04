import Foundation

struct Lesson: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var desc: String
    var content: String
    var userId: String?
}
