import Foundation

struct NumberItem: Identifiable, Equatable {
    let id: UUID
    let number: Int
    let displayText: String
    let imageName: String
    let objectCount: Int
    let speechText: String

    init(id: UUID = UUID(), number: Int, displayText: String, imageName: String, objectCount: Int, speechText: String) {
        self.id = id
        self.number = number
        self.displayText = displayText
        self.imageName = imageName
        self.objectCount = objectCount
        self.speechText = speechText
    }
}
