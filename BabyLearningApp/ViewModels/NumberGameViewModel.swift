import Foundation
import Observation

@MainActor
@Observable
final class NumberGameViewModel {
    enum FeedbackState {
        case idle
        case correct
        case wrong
    }

    private(set) var maxNumberValue: Int
    private(set) var language: LearningLanguage
    private(set) var childName = ""

    private(set) var targetNumber = 1
    private(set) var options: [Int] = []
    private(set) var selectedNumber: Int?
    private(set) var feedbackState: FeedbackState = .idle
    private(set) var feedbackText = ""
    private(set) var speechText = ""
    private(set) var wrongAttemptCount = 0
    private(set) var hintLevel = 0
    private(set) var isInputLocked = false

    init(maxNumberValue: Int = 10, languageCode: String = "vi-VN") {
        self.maxNumberValue = Self.validMaxNumber(maxNumberValue)
        self.language = LearningLanguage.from(languageCode)
        generateNewRound()
    }

    func generateNewRound() {
        let numberRange = Array(1...maxNumberValue)
        targetNumber = numberRange.randomElement() ?? 1
        selectedNumber = nil
        feedbackState = .idle
        feedbackText = ""
        wrongAttemptCount = 0
        hintLevel = 0
        isInputLocked = false
        updateQuestionSpeechText()

        let wrongNumbers = numberRange
            .filter { $0 != targetNumber }
            .shuffled()
            .prefix(2)

        options = ([targetNumber] + wrongNumbers).shuffled()
    }

    func updateMaxNumberValue(_ value: Int) {
        let validValue = Self.validMaxNumber(value)
        guard validValue != maxNumberValue else { return }
        maxNumberValue = validValue
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

    func selectNumber(_ number: Int) {
        guard feedbackState != .correct, !isInputLocked else { return }

        selectedNumber = number

        if number == targetNumber {
            let praise = PersonalizationService.praise(childName: childName)
            feedbackState = .correct
            feedbackText = praise
            speechText = praise
            wrongAttemptCount = 0
            hintLevel = 0
            isInputLocked = false
        } else {
            wrongAttemptCount += 1
            hintLevel = min(wrongAttemptCount, 3)
            isInputLocked = true
            feedbackState = .wrong
            feedbackText = PersonalizationService.retryText(childName: childName, hintLevel: hintLevel)
            speechText = PersonalizationService.retrySpeech(childName: childName, hintLevel: hintLevel)
        }
    }

    func unlockInput() {
        guard feedbackState != .correct else { return }
        isInputLocked = false
    }

    func shouldShowOption(_ number: Int) -> Bool {
        hintLevel < 3 || number == targetNumber
    }

    func shouldHighlightOption(_ number: Int) -> Bool {
        hintLevel > 0 && number == targetNumber
    }

    private static func validMaxNumber(_ value: Int) -> Int {
        min(max(value, 3), 10)
    }

    private func updateQuestionSpeechText() {
        speechText = PersonalizationService.numberPrompt(targetNumber, childName: childName)
    }
}
