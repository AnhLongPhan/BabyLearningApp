import Foundation

struct MathQuestion: Identifiable, Equatable {
    let id: UUID
    let leftNumber: Int
    let rightNumber: Int
    let correctAnswer: Int
    let options: [Int]
    let speechText: String

    init(id: UUID = UUID(), leftNumber: Int, rightNumber: Int, options: [Int], speechText: String) {
        self.id = id
        self.leftNumber = leftNumber
        self.rightNumber = rightNumber
        self.correctAnswer = leftNumber + rightNumber
        self.options = options
        self.speechText = speechText
    }
}
