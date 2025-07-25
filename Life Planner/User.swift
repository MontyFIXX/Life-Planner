import Foundation

struct User: Identifiable, Codable {
    var id: String
    var nickname: String
    var email: String
    var avatarURL: String?
    
    init(id: String, nickname: String, email: String, avatarURL: String? = nil) {
        self.id = id
        self.nickname = nickname
        self.email = email
        self.avatarURL = avatarURL
    }
}
