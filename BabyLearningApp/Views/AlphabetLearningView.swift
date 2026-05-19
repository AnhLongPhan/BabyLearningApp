import SwiftUI

struct AlphabetLearningView: View {
    @AppStorage("enabledAlphabetCharacters") private var enabledAlphabetCharacters = "ABC"
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = ""
    @State private var viewModel = AlphabetGameViewModel()
    @State private var audioService = AudioService()
    @State private var floatingBubbles = false
    @State private var nextRoundTask: Task<Void, Never>?

    private let bubbleColors: [Color] = [.orange, .teal, .pink, .purple, .mint]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    var body: some View {
        ZStack {
            FloatingBackgroundView(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.88),
                    Color(red: 0.94, green: 0.98, blue: 1.0),
                    Color(red: 1.0, green: 0.93, blue: 0.98)
                ],
                symbols: ["sparkles", "star.fill", "heart.fill", "circle.fill"]
            )

            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        MascotView(emoji: "🐥", message: "Tìm chữ nhé")
                        Spacer()
                        StickerRewardView(count: stickerRewardCount)
                    }

                    LearningCardView(backgroundColor: .orange.opacity(0.18)) {
                        Text("Đâu là chữ \(viewModel.targetLetter)?")
                            .font(.system(size: 36, weight: .black))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.75)

                        AudioReplayButton {
                            replayQuestion()
                        }

                        bubblePlayArea

                        feedbackView
                    }
                }
                .padding(16)
            }

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
        }
        .navigationTitle("Chữ cái")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateEnabledLetters(enabledAlphabetCharacters)
            floatingBubbles = true
            audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: enabledAlphabetCharacters) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateEnabledLetters(newValue)
            audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: speechLanguageCode) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateLanguage(newValue)
            audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: childName) { _, newValue in
            viewModel.updateChildName(newValue)
        }
        .onDisappear {
            nextRoundTask?.cancel()
            audioService.stop()
        }
    }

    private var feedbackView: some View {
        HStack(spacing: 10) {
            if viewModel.feedbackState == .correct {
                Image(systemName: "sparkles")
                Image(systemName: "checkmark.circle.fill")
            }

            Text(viewModel.feedbackText)
                .font(.system(size: 28, weight: .bold))
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(feedbackColor)
        .frame(height: 42)
    }

    private var feedbackColor: Color {
        switch viewModel.feedbackState {
        case .idle:
            return .clear
        case .correct:
            return .green
        case .wrong:
            return .orange
        }
    }

    private var bubblePlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    LetterBubbleView(
                        letter: option.letter,
                        color: bubbleColors[index % bubbleColors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: floatingBubbles,
                        animationDelay: Double(index) * 0.14
                    ) {
                        selectLetter(option.letter)
                    }
                    .frame(width: bubbleSize(in: geometry.size), height: bubbleSize(in: geometry.size))
                    .position(
                        x: geometry.size.width * option.xRatio,
                        y: geometry.size.height * option.yRatio
                    )
                    .disabled(viewModel.feedbackState == .correct)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 320)
        }
        .frame(height: 330)
    }

    private func bubbleSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.30, 108), 142)
    }

    private func isCorrect(_ option: LetterBubbleOption) -> Bool {
        viewModel.feedbackState == .correct && viewModel.selectedLetter == option.letter
    }

    private func isWrong(_ option: LetterBubbleOption) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedLetter == option.letter
    }

    private func selectLetter(_ letter: String) {
        nextRoundTask?.cancel()
        viewModel.selectLetter(letter)

        switch viewModel.feedbackState {
        case .correct:
            stickerRewardCount += 1
            nextRoundTask = Task {
                async let minimumWait: Void = waitBeforeNextRound()
                await audioService.speakAndWait(viewModel.praiseSpeechText, language: viewModel.language.speechCode)
                guard !Task.isCancelled else { return }
                await audioService.speakAndWait(viewModel.confirmationSpeechText, language: viewModel.language.speechCode)
                await minimumWait
                guard !Task.isCancelled else { return }
                viewModel.generateNewRound()
                audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
            }
        case .wrong:
            audioService.speak(viewModel.wrongSpeechText, language: viewModel.language.speechCode)
        case .idle:
            break
        }
    }

    private func replayQuestion() {
        audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
    }

    private func waitBeforeNextRound() async {
        try? await Task.sleep(for: minimumCorrectFeedbackDuration)
    }
}

#Preview {
    NavigationStack {
        AlphabetLearningView()
    }
}
