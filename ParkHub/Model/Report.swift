import Foundation

struct Report: Identifiable, Codable, Hashable {
    var id: String { reportId }
    var reportId: String = UUID().uuidString
    var userId: String = ""
    var username: String = ""
    var title: String = ""
    var description: String = ""
    var timestamp: Double = Date().timeIntervalSince1970 * 1000
}
