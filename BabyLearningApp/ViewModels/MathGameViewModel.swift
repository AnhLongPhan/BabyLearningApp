import Foundation
import Observation

struct MathAnswerOption: Identifiable, Equatable {
    let id = UUID()
    let value: Int
    let xRatio: Double
    let yRatio: Double
}

@MainActor
@Observable
final class MathGameViewModel {
    enum FeedbackState {
        case idle
        case correct
        case wrong
    }

    private(set) var selectedTheme: MathObjectTheme = .apple
    private(set) var objectEmoji = MathObjectTheme.apple.emoji
    private(set) var leftNumber = 1
    private(set) var rightNumber = 1
    private(set) var correctAnswer = 2
    private(set) var options: [MathAnswerOption] = []
    private(set) var selectedAnswer: Int?
    private(set) var feedbackState: FeedbackState = .idle
    private(set) var feedbackText = ""
    private(set) var questionSpeechText = ""
    private(set) var responseSpeechText = ""
    private(set) var totalCorrectAnswers: Int
    private(set) var wrongAttemptCount = 0
    private(set) var maxMathSum: Int
    private(set) var language: LearningLanguage
    private(set) var childName = ""
    private(set) var roundID = UUID()

    init(maxMathSum: Int = 5, totalCorrectAnswers: Int = 0, languageCode: String = "vi-VN") {
        self.maxMathSum = Self.validMaxMathSum(maxMathSum)
        self.totalCorrectAnswers = totalCorrectAnswers
        self.language = LearningLanguage.from(languageCode)
        generateNewRound()
    }

    func generateNewRound() {
        selectedTheme = MathObjectTheme.allCases.randomElement() ?? .apple
        objectEmoji = selectedTheme.emoji
        correctAnswer = Int.random(in: 2...maxMathSum)
        leftNumber = Int.random(in: 1..<correctAnswer)
        rightNumber = correctAnswer - leftNumber
        selectedAnswer = nil
        feedbackState = .idle
        feedbackText = ""
        responseSpeechText = ""
        questionSpeechText = language.mathQuestion(
            leftNumber: leftNumber,
            rightNumber: rightNumber,
            objectName: selectedTheme.speechName(for: language),
            childName: childName
        )

        let wrongAnswers = Array(1...10)
            .filter { $0 != correctAnswer }
            .shuffled()
            .prefix(2)

        let values = ([correctAnswer] + wrongAnswers).shuffled()
        let positions = Self.makeOptionPositions(count: values.count)
        options = zip(values, positions).map { value, position in
            MathAnswerOption(value: value, xRatio: position.xRatio, yRatio: position.yRatio)
        }
        roundID = UUID()
    }

    func selectAnswer(_ answer: Int) {
        guard feedbackState != .correct else { return }

        selectedAnswer = answer

        if answer == correctAnswer {
            let basePraise = language.mathPraiseSentences.randomElement() ?? language.correctFeedback
            let praise = language.personalizedPraise(basePraise, childName: childName)
            feedbackState = .correct
            feedbackText = praise
            responseSpeechText = praise
            totalCorrectAnswers += 1
        } else {
            feedbackState = .wrong
            feedbackText = language.retryFeedback(childName: childName)
            responseSpeechText = language.wrongSpeechText(childName: childName)
            wrongAttemptCount += 1
        }
    }

    func updateMaxMathSum(_ value: Int) {
        let validValue = Self.validMaxMathSum(value)
        guard validValue != maxMathSum else { return }
        maxMathSum = validValue
        generateNewRound()
    }

    func updateTotalCorrectAnswers(_ total: Int) {
        totalCorrectAnswers = max(total, 0)
    }

    func updateLanguage(_ languageCode: String) {
        let newLanguage = LearningLanguage.from(languageCode)
        guard newLanguage != language else { return }
        language = newLanguage
        generateNewRound()
    }

    func updateChildName(_ name: String) {
        childName = name
        updateQuestionSpeechText()
    }

    private func updateQuestionSpeechText() {
        questionSpeechText = language.mathQuestion(
            leftNumber: leftNumber,
            rightNumber: rightNumber,
            objectName: selectedTheme.speechName(for: language),
            childName: childName
        )
    }

    private static func validMaxMathSum(_ value: Int) -> Int {
        min(max(value, 2), 10)
    }

    private static func makeOptionPositions(count: Int) -> [(xRatio: Double, yRatio: Double)] {
        Array([
            (xRatio: 0.24, yRatio: 0.36),
            (xRatio: 0.76, yRatio: 0.34),
            (xRatio: 0.52, yRatio: 0.74)
        ].shuffled().prefix(count))
    }
}
