import Foundation

struct ChildProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var avatarEmoji: String
    var age: Int

    init(id: UUID = UUID(), name: String = "Bé", avatarEmoji: String = "😊", age: Int = 3) {
        self.id = id
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.age = age
    }
}
