import Foundation
import Observation

@MainActor
@Observable
final class MathViewModel {
    enum AnswerState: Equatable {
        case unanswered
        case correct
        case incorrect
    }

    private(set) var currentQuestion: MathQuestion
    private(set) var maxMathSum: Int
    private(set) var answerState: AnswerState = .unanswered
    private(set) var totalCorrectAnswers: Int
    private(set) var selectedAnswer: Int?

    init(maxMathSum: Int = 5, totalCorrectAnswers: Int = 0) {
        let validMaxMathSum = Self.validMaxMathSum(maxMathSum)
        self.maxMathSum = validMaxMathSum
        self.currentQuestion = Self.makeQuestion(maxMathSum: validMaxMathSum)
        self.totalCorrectAnswers = totalCorrectAnswers
    }

    func selectAnswer(_ answer: Int) {
        selectedAnswer = answer

        if answer == currentQuestion.correctAnswer {
            answerState = .correct
            totalCorrectAnswers += 1
        } else {
            answerState = .incorrect
        }
    }

    func updateTotalCorrectAnswers(_ total: Int) {
        totalCorrectAnswers = max(total, 0)
    }

    func moveToNextQuestion() {
        currentQuestion = Self.makeQuestion(maxMathSum: maxMathSum)
        selectedAnswer = nil
        answerState = .unanswered
    }

    func updateMaxMathSum(_ value: Int) {
        let validValue = Self.validMaxMathSum(value)
        guard validValue != maxMathSum else { return }
        maxMathSum = validValue
        moveToNextQuestion()
    }

    private static func makeQuestion(maxMathSum: Int) -> MathQuestion {
        let validMaxSum = validMaxMathSum(maxMathSum)
        let correctAnswer = Int.random(in: 2...validMaxSum)
        let leftNumber = Int.random(in: 1..<correctAnswer)
        let rightNumber = correctAnswer - leftNumber
        let wrongOptions = Array(1...10)
            .filter { $0 != correctAnswer }
            .shuffled()
            .prefix(2)
        let options = ([correctAnswer] + wrongOptions).shuffled()

        return MathQuestion(
            leftNumber: leftNumber,
            rightNumber: rightNumber,
            options: options,
            speechText: "\(leftNumber) cộng \(rightNumber) bằng mấy?"
        )
    }

    private static func validMaxMathSum(_ value: Int) -> Int {
        min(max(value, 2), 10)
    }
}
