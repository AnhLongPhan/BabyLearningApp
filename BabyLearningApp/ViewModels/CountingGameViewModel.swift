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
    private(set) var hintLevel = 0
    private(set) var isInputLocked = false
    private var enabledThemes: [MathObjectTheme]

    init(maxCount: Int = 10, languageCode: String = "vi-VN", enabledThemeIDs: String? = nil) {
        self.maxCount = Self.validMaxCount(maxCount)
        self.language = LearningLanguage.from(languageCode)
        self.enabledThemes = MathObjectTheme.themes(from: enabledThemeIDs ?? MathObjectTheme.defaultStorageValue)
        generateNewRound()
    }

    func generateNewRound() {
        theme = enabledThemes.randomElement() ?? .apple
        objectEmoji = theme.emoji
        objectCount = Int.random(in: 1...maxCount)
        selectedAnswer = nil
        feedbackState = .idle
        feedbackText = ""
        responseSpeechText = ""
        wrongAttemptCount = 0
        hintLevel = 0
        isInputLocked = false
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
        guard feedbackState != .correct, !isInputLocked else { return }

        selectedAnswer = answer

        if answer == objectCount {
            let praise = PersonalizationService.praise(childName: childName)
            feedbackState = .correct
            feedbackText = praise
            responseSpeechText = praise
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

    func shouldShowOption(_ option: CountingAnswerOption) -> Bool {
        hintLevel < 3 || option.value == objectCount
    }

    func shouldHighlightOption(_ option: CountingAnswerOption) -> Bool {
        hintLevel > 0 && option.value == objectCount
    }

    func updateMaxCount(_ value: Int) {
        let validValue = Self.validMaxCount(value)
        guard validValue != maxCount else { return }
        maxCount = validValue

        if objectCount > validValue {
            generateNewRound()
        }
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
        updateQuestionSpeechText()
    }

    func updateChildName(_ name: String) {
        childName = name
        updateQuestionSpeechText()
    }

    private func updateQuestionSpeechText() {
        questionSpeechText = PersonalizationService.countingPrompt(objectName: theme.speechName(for: language), childName: childName)
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
