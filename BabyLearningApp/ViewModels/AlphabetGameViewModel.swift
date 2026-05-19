import Foundation
import Observation

struct LetterBubbleOption: Identifiable, Equatable {
    let id = UUID()
    let letter: String
    let xRatio: Double
    let yRatio: Double
}

@MainActor
@Observable
final class AlphabetGameViewModel {
    enum FeedbackState {
        case idle
        case correct
        case wrong
    }

    private let allItems: [AlphabetItem]

    private(set) var language: LearningLanguage
    private(set) var childName = ""
    private(set) var enabledLetters = "ABC"
    private(set) var targetLetter = "A"
    private(set) var options: [LetterBubbleOption] = []
    private(set) var selectedLetter: String?
    private(set) var feedbackState: FeedbackState = .idle
    private(set) var feedbackText = ""
    private(set) var promptSpeechText = ""
    private(set) var praiseSpeechText = ""
    private(set) var confirmationSpeechText = ""
    private(set) var wrongSpeechText = ""
    private(set) var wrongAttemptCount = 0

    init(items: [AlphabetItem] = SampleLearningData.alphabetItems, enabledLetters: String = "ABC", languageCode: String = "vi-VN") {
        self.allItems = items
        self.enabledLetters = enabledLetters
        self.language = LearningLanguage.from(languageCode)
        generateNewRound()
    }

    func updateEnabledLetters(_ letters: String) {
        enabledLetters = letters
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
        updateWrongSpeechText()
    }

    func generateNewRound() {
        let availableItems = filteredItems()
        let targetItem = availableItems.randomElement() ?? allItems[0]
        targetLetter = targetItem.letter
        selectedLetter = nil
        feedbackState = .idle
        feedbackText = ""
        updateQuestionSpeechText()
        praiseSpeechText = ""
        confirmationSpeechText = language.letterConfirmation(targetLetter)
        updateWrongSpeechText()

        let wrongLetters = allItems
            .map(\.letter)
            .filter { $0.uppercased() != targetLetter.uppercased() }
            .shuffled()
            .prefix(2)

        let letters = ([targetLetter] + wrongLetters).shuffled()
        let positions = Self.makeBubblePositions(count: letters.count)
        options = zip(letters, positions).map { letter, position in
            LetterBubbleOption(letter: letter, xRatio: position.xRatio, yRatio: position.yRatio)
        }
    }

    func selectLetter(_ letter: String) {
        guard feedbackState != .correct else { return }

        selectedLetter = letter

        if letter.uppercased() == targetLetter.uppercased() {
            let basePraise = language.alphabetPraiseSentences.randomElement() ?? language.correctFeedback
            let praise = language.personalizedPraise(basePraise, childName: childName)
            feedbackState = .correct
            feedbackText = praise
            praiseSpeechText = praise
            confirmationSpeechText = language.letterConfirmation(targetLetter)
        } else {
            feedbackState = .wrong
            feedbackText = language.retryFeedback(childName: childName)
            wrongAttemptCount += 1
        }
    }

    private func filteredItems() -> [AlphabetItem] {
        let enabledSet = Set(enabledLetters.uppercased().map(String.init))
        let filteredItems = allItems.filter { enabledSet.contains($0.letter.uppercased()) }
        return filteredItems.isEmpty ? allItems : filteredItems
    }

    private func updateQuestionSpeechText() {
        promptSpeechText = language.findLetterPrompt(targetLetter, childName: childName)
    }

    private func updateWrongSpeechText() {
        wrongSpeechText = language.wrongSpeechText(childName: childName)
    }

    private static func makeBubblePositions(count: Int) -> [(xRatio: Double, yRatio: Double)] {
        var positions: [(xRatio: Double, yRatio: Double)] = []
        let minimumDistance = 0.34
        var attempts = 0

        while positions.count < count && attempts < 120 {
            attempts += 1
            let candidate = (
                xRatio: Double.random(in: 0.22...0.78),
                yRatio: Double.random(in: 0.24...0.76)
            )

            let isFarEnough = positions.allSatisfy { position in
                let dx = candidate.xRatio - position.xRatio
                let dy = candidate.yRatio - position.yRatio
                return sqrt(dx * dx + dy * dy) >= minimumDistance
            }

            if isFarEnough {
                positions.append(candidate)
            }
        }

        if positions.count < count {
            let fallbackPositions = [
                (xRatio: 0.28, yRatio: 0.30),
                (xRatio: 0.74, yRatio: 0.42),
                (xRatio: 0.46, yRatio: 0.72)
            ].shuffled()

            positions = Array(fallbackPositions.prefix(count))
        }

        return positions
    }
}
