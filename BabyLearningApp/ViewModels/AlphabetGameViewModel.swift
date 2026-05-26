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

    enum PlayPhase {
        case explore
        case challenge
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
    private(set) var letterSoundText = ""
    private(set) var praiseSpeechText = ""
    private(set) var confirmationSpeechText = ""
    private(set) var wrongSpeechText = ""
    private(set) var wrongAttemptCount = 0
    private(set) var hintLevel = 0
    private(set) var isInputLocked = false
    private(set) var playPhase: PlayPhase = .explore
    private(set) var mascotMessage = ""
    private(set) var exploredLetter: String?
    private(set) var exploredLetters: Set<String> = []

    init(items: [AlphabetItem]? = nil, enabledLetters: String = "ABC", languageCode: String = "vi-VN") {
        self.allItems = items ?? SampleLearningData.alphabetItems
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
        exploredLetter = nil
        exploredLetters = []
        playPhase = .explore
        feedbackState = .idle
        feedbackText = ""
        wrongAttemptCount = 0
        hintLevel = 0
        isInputLocked = false
        updateQuestionSpeechText()
        letterSoundText = PersonalizationService.letterSound(targetLetter)
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
        guard feedbackState != .correct, !isInputLocked else { return }

        guard playPhase == .challenge else {
            exploreLetter(letter)
            return
        }

        selectedLetter = letter

        if letter.uppercased() == targetLetter.uppercased() {
            let praise = PersonalizationService.praise(childName: childName)
            feedbackState = .correct
            feedbackText = praise
            praiseSpeechText = praise
            confirmationSpeechText = language.letterConfirmation(targetLetter)
            wrongAttemptCount = 0
            hintLevel = 0
            isInputLocked = false
        } else {
            wrongAttemptCount += 1
            hintLevel = min(wrongAttemptCount, 3)
            isInputLocked = true
            feedbackState = .wrong
            feedbackText = PersonalizationService.retryText(childName: childName, hintLevel: hintLevel)
            wrongSpeechText = PersonalizationService.retrySpeech(childName: childName, hintLevel: hintLevel)
        }
    }

    func startChallenge() {
        guard feedbackState != .correct else { return }
        exploredLetter = nil
        playPhase = .challenge
        mascotMessage = PersonalizationService.letterChallengePrompt(targetLetter, childName: childName)
        promptSpeechText = mascotMessage
        letterSoundText = PersonalizationService.letterSound(targetLetter)
    }

    func exploreLetter(_ letter: String) {
        exploredLetter = letter
        exploredLetters.insert(letter.uppercased())
        mascotMessage = "Đây là chữ \(letter)"
        letterSoundText = PersonalizationService.letterSound(letter)
    }

    var hasExploredAllOptions: Bool {
        exploredLetters.count >= options.count
    }

    func unlockInput() {
        guard feedbackState != .correct else { return }
        isInputLocked = false
    }

    func shouldShowOption(_ option: LetterBubbleOption) -> Bool {
        hintLevel < 3 || option.letter.uppercased() == targetLetter.uppercased()
    }

    func shouldHighlightOption(_ option: LetterBubbleOption) -> Bool {
        hintLevel > 0 && option.letter.uppercased() == targetLetter.uppercased()
    }

    private func filteredItems() -> [AlphabetItem] {
        let enabledSet = Set(enabledLetters.uppercased().map(String.init))
        let filteredItems = allItems.filter { enabledSet.contains($0.letter.uppercased()) }
        return filteredItems.isEmpty ? allItems : filteredItems
    }

    private func updateQuestionSpeechText() {
        mascotMessage = PersonalizationService.letterExplorePrompt(childName: childName)
        promptSpeechText = mascotMessage
    }

    private func updateWrongSpeechText() {
        wrongSpeechText = PersonalizationService.retrySpeech(childName: childName, hintLevel: max(hintLevel, 1))
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
