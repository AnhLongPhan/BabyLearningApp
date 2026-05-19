import Foundation
import Observation

struct CountingAnswerOption: Identifiable, Equatable {
    let id = UUID()
    let value: Int
    let xRatio: Double
    let yRatio: Double
}

@MainActor
@Observable
final class CountingGameViewModel: GameRoundViewModel {
    enum FeedbackState {
        case idle
        case correct
        case wrong
    }

    private(set) var theme: MathObjectTheme = .apple
    private(set) var objectEmoji = MathObjectTheme.apple.emoji
    private(set) var objectCount = 1
    private(set) var options: [CountingAnswerOption] = []
    private(set) var selectedAnswer: Int?
    private(set) var feedbackState: FeedbackState = .idle
    private(set) var feedbackText = ""
    private(set) var questionSpeechText = ""
    private(set) var responseSpeechText = ""
    private(set) var wrongAttemptCount = 0
    private(set) var language: LearningLanguage
    private(set) var childName = ""
    private(set) var maxCount: Int

    init(maxCount: Int = 10, languageCode: String = "vi-VN") {
        self.maxCount = Self.validMaxCount(maxCount)
        self.language = LearningLanguage.from(languageCode)
        generateNewRound()
    }

    func generateNewRound() {
        theme = MathObjectTheme.allCases.randomElement() ?? .apple
        objectEmoji = theme.emoji
        objectCount = Int.random(in: 1...maxCount)
        selectedAnswer = nil
        feedbackState = .idle
        feedbackText = ""
        responseSpeechText = ""
        updateQuestionSpeechText()

        let wrongAnswers = Array(1...10)
            .filter { $0 != objectCount }
            .shuffled()
            .prefix(2)
        let values = ([objectCount] + wrongAnswers).shuffled()
        let positions = Self.makeOptionPositions(count: values.count)
        options = zip(values, positions).map { value, position in
            CountingAnswerOption(value: value, xRatio: position.xRatio, yRatio: position.yRatio)
        }
    }

    func selectAnswer(_ answer: Int) {
        guard feedbackState != .correct else { return }

        selectedAnswer = answer

        if answer == objectCount {
            let basePraise = language.numberPraiseSentences.randomElement() ?? language.correctFeedback
            let praise = language.personalizedPraise(basePraise, childName: childName)
            feedbackState = .correct
            feedbackText = praise
            responseSpeechText = praise
        } else {
            feedbackState = .wrong
            feedbackText = language.retryFeedback(childName: childName)
            responseSpeechText = language.wrongSpeechText(childName: childName)
            wrongAttemptCount += 1
        }
    }

    func updateMaxCount(_ value: Int) {
        let validValue = Self.validMaxCount(value)
        guard validValue != maxCount else { return }
        maxCount = validValue

        if objectCount > validValue {
            generateNewRound()
        }
    }

    func updateLanguage(_ languageCode: String) {
        let newLanguage = LearningLanguage.from(languageCode)
        guard newLanguage != language else { return }
        language = newLanguage
        updateQuestionSpeechText()
    }

    func updateChildName(_ name: String) {
        childName = name
        updateQuestionSpeechText()
    }

    private func updateQuestionSpeechText() {
        questionSpeechText = language.countingQuestion(objectName: theme.speechName(for: language), childName: childName)
    }

    private static func validMaxCount(_ value: Int) -> Int {
        min(max(value, 3), 10)
    }

    private static func makeOptionPositions(count: Int) -> [(xRatio: Double, yRatio: Double)] {
        Array([
            (xRatio: 0.22, yRatio: 0.36),
            (xRatio: 0.78, yRatio: 0.34),
            (xRatio: 0.50, yRatio: 0.76)
        ].shuffled().prefix(count))
    }
}
