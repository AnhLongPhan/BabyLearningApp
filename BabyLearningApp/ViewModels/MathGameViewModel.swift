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
    private(set) var hintLevel = 0
    private(set) var isInputLocked = false
    private var enabledThemes: [MathObjectTheme]

    init(maxMathSum: Int = 5, totalCorrectAnswers: Int = 0, languageCode: String = "vi-VN", enabledThemeIDs: String? = nil) {
        self.maxMathSum = Self.validMaxMathSum(maxMathSum)
        self.totalCorrectAnswers = totalCorrectAnswers
        self.language = LearningLanguage.from(languageCode)
        self.enabledThemes = MathObjectTheme.themes(from: enabledThemeIDs ?? MathObjectTheme.defaultStorageValue)
        generateNewRound()
    }

    func generateNewRound() {
        selectedTheme = enabledThemes.randomElement() ?? .apple
        objectEmoji = selectedTheme.emoji
        correctAnswer = Int.random(in: 2...maxMathSum)
        leftNumber = Int.random(in: 1..<correctAnswer)
        rightNumber = correctAnswer - leftNumber
        selectedAnswer = nil
        feedbackState = .idle
        feedbackText = ""
        responseSpeechText = ""
        wrongAttemptCount = 0
        hintLevel = 0
        isInputLocked = false
        questionSpeechText = PersonalizationService.mathPrompt(
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
        guard feedbackState != .correct, !isInputLocked else { return }

        selectedAnswer = answer

        if answer == correctAnswer {
            let praise = PersonalizationService.praise(childName: childName)
            feedbackState = .correct
            feedbackText = praise
            responseSpeechText = praise
            totalCorrectAnswers += 1
            wrongAttemptCount = 0
            hintLevel = 0
            isInputLocked = false
        } else {
            wrongAttemptCount += 1
            hintLevel = min(wrongAttemptCount, 3)
            isInputLocked = true
            feedbackState = .wrong
            feedbackText = PersonalizationService.retryText(childName: childName, hintLevel: hintLevel)
            responseSpeechText = PersonalizationService.retrySpeech(childName: childName, hintLevel: hintLevel)
        }
    }

    func unlockInput() {
        guard feedbackState != .correct else { return }
        isInputLocked = false
    }

    func shouldShowOption(_ option: MathAnswerOption) -> Bool {
        hintLevel < 3 || option.value == correctAnswer
    }

    func shouldHighlightOption(_ option: MathAnswerOption) -> Bool {
        hintLevel > 0 && option.value == correctAnswer
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

    func updateEnabledThemes(_ themeIDs: String) {
        let themes = MathObjectTheme.themes(from: themeIDs)
        guard themes.map(\.rawValue) != enabledThemes.map(\.rawValue) else { return }
        enabledThemes = themes
        generateNewRound()
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
        questionSpeechText = PersonalizationService.mathPrompt(
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
