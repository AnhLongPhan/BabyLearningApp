import Foundation
import Observation

struct ListenAndPickOption: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let xRatio: Double
    let yRatio: Double
}

enum ListenAndPickMode: String, Identifiable {
    case alphabet
    case number

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alphabet:
            return "Nghe chọn chữ"
        case .number:
            return "Nghe chọn số"
        }
    }

    var mascotEmoji: String {
        switch self {
        case .alphabet:
            return "🦜"
        case .number:
            return "🐳"
        }
    }
}

@MainActor
@Observable
final class ListenAndPickGameViewModel {
    enum FeedbackState {
        case idle
        case correct
        case wrong
    }

    private(set) var mode: ListenAndPickMode
    private(set) var language: LearningLanguage
    private(set) var childName = ""
    private(set) var enabledLetters = "ABC"
    private(set) var maxNumberValue = 10
    private(set) var targetValue = "A"
    private(set) var options: [ListenAndPickOption] = []
    private(set) var selectedValue: String?
    private(set) var feedbackState: FeedbackState = .idle
    private(set) var feedbackText = ""
    private(set) var promptSpeechText = ""
    private(set) var responseSpeechText = ""
    private(set) var wrongAttemptCount = 0
    private(set) var hintLevel = 0
    private(set) var isInputLocked = false

    init(mode: ListenAndPickMode, languageCode: String = "vi-VN") {
        self.mode = mode
        self.language = LearningLanguage.from(languageCode)
        generateNewRound()
    }

    func generateNewRound() {
        selectedValue = nil
        feedbackState = .idle
        feedbackText = ""
        responseSpeechText = ""
        wrongAttemptCount = 0
        hintLevel = 0
        isInputLocked = false

        switch mode {
        case .alphabet:
            makeAlphabetRound()
        case .number:
            makeNumberRound()
        }
    }

    func selectValue(_ value: String) {
        guard feedbackState != .correct, !isInputLocked else { return }
        selectedValue = value

        if value == targetValue {
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

    func shouldShowOption(_ option: ListenAndPickOption) -> Bool {
        hintLevel < 3 || option.value == targetValue
    }

    func shouldHighlightOption(_ option: ListenAndPickOption) -> Bool {
        hintLevel > 0 && option.value == targetValue
    }

    func updateLanguage(_ languageCode: String) {
        let newLanguage = LearningLanguage.from(languageCode)
        guard newLanguage != language else { return }
        language = newLanguage
        generateNewRound()
    }

    func updateChildName(_ name: String) {
        childName = name
        updatePromptSpeechText()
    }

    func updateEnabledLetters(_ letters: String) {
        enabledLetters = letters
        if mode == .alphabet {
            generateNewRound()
        }
    }

    func updateMaxNumberValue(_ value: Int) {
        maxNumberValue = min(max(value, 3), 10)
        if mode == .number {
            generateNewRound()
        }
    }

    private func makeAlphabetRound() {
        let allLetters = SampleLearningData.alphabetItems.map(\.letter)
        let enabledSet = Set(enabledLetters.uppercased().map(String.init))
        let availableLetters = allLetters.filter { enabledSet.contains($0.uppercased()) }
        let letters = availableLetters.isEmpty ? allLetters : availableLetters
        targetValue = letters.randomElement() ?? "A"

        let wrongLetters = allLetters.filter { $0 != targetValue }.shuffled().prefix(2)
        setOptions(([targetValue] + wrongLetters).shuffled())
        updatePromptSpeechText()
    }

    private func makeNumberRound() {
        let numbers = Array(1...maxNumberValue).map(String.init)
        targetValue = numbers.randomElement() ?? "1"

        let wrongNumbers = numbers.filter { $0 != targetValue }.shuffled().prefix(2)
        setOptions(([targetValue] + wrongNumbers).shuffled())
        updatePromptSpeechText()
    }

    private func setOptions(_ values: [String]) {
        let positions = [
            (xRatio: 0.24, yRatio: 0.34),
            (xRatio: 0.76, yRatio: 0.34),
            (xRatio: 0.50, yRatio: 0.74)
        ].shuffled()

        options = zip(values, positions).map { value, position in
            ListenAndPickOption(value: value, xRatio: position.xRatio, yRatio: position.yRatio)
        }
    }

    private func updatePromptSpeechText() {
        switch mode {
        case .alphabet:
            promptSpeechText = PersonalizationService.letterPrompt(targetValue, childName: childName)
        case .number:
            promptSpeechText = PersonalizationService.numberPrompt(Int(targetValue) ?? 1, childName: childName)
        }
    }
}
