import SwiftUI

struct AlphabetLearningView: View {
    let showsBackButton: Bool

    @AppStorage("enabledAlphabetCharacters") private var enabledAlphabetCharacters = "ABC"
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = "Bé"
    @State private var viewModel = AlphabetGameViewModel()
    @State private var audioService = AudioService()
    @State private var floatingBubbles = false
    @State private var nextRoundTask: Task<Void, Never>?
    @State private var explorationAudioTask: Task<Void, Never>?
    @State private var showGiftReward = false
    @State private var isExplorationAudioPlaying = false

    private let bubbleColors: [Color] = [.orange, .teal, .pink, .purple, .mint]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    init(showsBackButton: Bool = true) {
        self.showsBackButton = showsBackButton
    }

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

            VStack(spacing: 12) {
                HStack {
                    MascotSpeechBubble(emoji: mascotEmoji, message: viewModel.mascotMessage)
                    Spacer()
                    StickerRewardView(count: stickerRewardCount)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                HStack(spacing: 12) {
                    Text(viewModel.playPhase == .explore ? "Chạm từng chữ" : "Pop chữ \(viewModel.targetLetter)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    AudioReplayButton(isCompact: true) {
                        replayQuestion()
                    }
                }
                .padding(.horizontal, 16)

                bubblePlayArea
                    .padding(.horizontal, 12)

                FeedbackOverlayView(
                    text: viewModel.feedbackText,
                    isCorrect: viewModel.feedbackState == .correct,
                    isWrong: viewModel.feedbackState == .wrong
                )
                .frame(height: 56)
            }

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
            GiftRewardPopupView(isVisible: showGiftReward, stickerCount: stickerRewardCount)
        }
        .navigationTitle("Letter Bubble Pop")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton(showsBackButton)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateEnabledLetters(enabledAlphabetCharacters)
            floatingBubbles = true
        }
        .onChange(of: enabledAlphabetCharacters) { _, newValue in
            nextRoundTask?.cancel()
            explorationAudioTask?.cancel()
            isExplorationAudioPlaying = false
            audioService.stop()
            viewModel.updateEnabledLetters(newValue)
        }
        .onChange(of: speechLanguageCode) { _, newValue in
            nextRoundTask?.cancel()
            explorationAudioTask?.cancel()
            isExplorationAudioPlaying = false
            audioService.stop()
            viewModel.updateLanguage(newValue)
        }
        .onChange(of: childName) { _, newValue in
            viewModel.updateChildName(newValue)
        }
        .onDisappear {
            nextRoundTask?.cancel()
            explorationAudioTask?.cancel()
            audioService.stop()
        }
    }

    private var mascotEmoji: String {
        ["🐰", "🐻", "🦁"].randomElement() ?? "🐰"
    }

    private var bubblePlayArea: some View {
        FloatingBubbleContainer(height: 470) { size in
            ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                ZStack {
                    LetterBubbleView(
                        letter: option.letter,
                        color: bubbleColors[index % bubbleColors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        isHinted: viewModel.shouldHighlightOption(option),
                        isExploring: viewModel.exploredLetter == option.letter,
                        isPopped: isCorrect(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: floatingBubbles,
                        animationDelay: Double(index) * 0.17
                    ) {
                        selectLetter(option.letter)
                    }
                    .frame(width: bubbleSize(in: size, index: index), height: bubbleSize(in: size, index: index))
                    .position(
                        x: size.width * option.xRatio,
                        y: size.height * option.yRatio
                    )
                    .opacity(viewModel.shouldShowOption(option) ? 1 : 0)
                    .disabled(viewModel.feedbackState == .correct || viewModel.isInputLocked || isExplorationAudioPlaying || !viewModel.shouldShowOption(option))

                    RewardEffectView(isActive: isCorrect(option))
                        .position(
                            x: size.width * option.xRatio,
                            y: size.height * option.yRatio
                        )
                }
            }
        }
    }

    private func bubbleSize(in size: CGSize, index: Int) -> CGFloat {
        let base = min(max(size.width * 0.34, 128), 168)
        return base + CGFloat(index % 2) * 12
    }

    private func isCorrect(_ option: LetterBubbleOption) -> Bool {
        viewModel.feedbackState == .correct && viewModel.selectedLetter == option.letter
    }

    private func isWrong(_ option: LetterBubbleOption) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedLetter == option.letter
    }

    private func selectLetter(_ letter: String) {
        nextRoundTask?.cancel()

        if viewModel.playPhase == .explore {
            playExplorationLetter(letter)
            return
        }

        viewModel.selectLetter(letter)

        switch viewModel.feedbackState {
        case .correct:
            stickerRewardCount += 1
            showGiftIfNeeded()
            nextRoundTask = Task {
                async let minimumWait: Void = waitBeforeNextRound()
                await audioService.speakAndWait(viewModel.praiseSpeechText, language: viewModel.language.speechCode)
                guard !Task.isCancelled else { return }
                await audioService.speakAndWait(viewModel.confirmationSpeechText, language: viewModel.language.speechCode)
                await minimumWait
                guard !Task.isCancelled else { return }
                viewModel.generateNewRound()
                isExplorationAudioPlaying = false
            }
        case .wrong:
            audioService.speak(viewModel.wrongSpeechText, language: viewModel.language.speechCode)
            nextRoundTask = Task {
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { return }
                viewModel.unlockInput()
            }
        case .idle:
            break
        }
    }

    private func replayQuestion() {
        explorationAudioTask?.cancel()
        isExplorationAudioPlaying = false
        if viewModel.playPhase == .explore {
            viewModel.startChallenge()
        }
        audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
    }

    private func playExplorationLetter(_ letter: String) {
        explorationAudioTask?.cancel()
        viewModel.exploreLetter(letter)
        isExplorationAudioPlaying = true

        explorationAudioTask = Task {
            await audioService.speakAndWait(viewModel.letterSoundText, language: viewModel.language.speechCode)
            guard !Task.isCancelled else { return }

            if viewModel.hasExploredAllOptions {
                viewModel.startChallenge()
                await audioService.speakAndWait(viewModel.promptSpeechText, language: viewModel.language.speechCode)
            }

            guard !Task.isCancelled else { return }
            isExplorationAudioPlaying = false
        }
    }

    private func waitBeforeNextRound() async {
        try? await Task.sleep(for: minimumCorrectFeedbackDuration)
    }

    private func showGiftIfNeeded() {
        guard stickerRewardCount % 5 == 0 else { return }
        withAnimation {
            showGiftReward = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            await MainActor.run {
                withAnimation {
                    showGiftReward = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlphabetLearningView()
    }
}
