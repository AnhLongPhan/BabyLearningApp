import Foundation
import Observation

@MainActor
@Observable
final class ChildProfileViewModel {
    private(set) var profile: ChildProfile

    init(name: String = "Bé", avatarEmoji: String = "😊", age: Int = 3) {
        self.profile = ChildProfile(name: name, avatarEmoji: avatarEmoji, age: age)
    }

    func update(name: String, avatarEmoji: String, age: Int) {
        profile.name = PersonalizationService.displayName(name)
        profile.avatarEmoji = avatarEmoji.isEmpty ? "😊" : avatarEmoji
        profile.age = min(max(age, 3), 6)
    }
}
