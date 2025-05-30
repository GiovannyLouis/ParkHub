
import Foundation

struct User: Codable, Identifiable {
    var id: String = ""
    var username: String = ""
    var token: String?
}

