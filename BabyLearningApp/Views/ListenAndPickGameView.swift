import SwiftUI

struct ListenAndPickGameView: View {
    let mode: ListenAndPickMode

    @AppStorage("enabledAlphabetCharacters") private var enabledAlphabetCharacters = "ABC"
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = "Bé"

    @State private var viewModel: ListenAndPickGameViewModel
    @State private var audioService = AudioService()
    @State private var isFloating = false
    @State private var nextRoundTask: Task<Void, Never>?
    @State private var showGiftReward = false

    private let colors: [Color] = [.orange, .teal, .pink]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    init(mode: ListenAndPickMode) {
        self.mode = mode
        _viewModel = State(initialValue: ListenAndPickGameViewModel(mode: mode))
    }

    var body: some View {
        ZStack {
            FloatingBackgroundView(
                colors: [
                    Color(red: 0.94, green: 0.98, blue: 1.0),
                    Color(red: 1.0, green: 0.95, blue: 0.88),
                    Color(red: 0.98, green: 0.93, blue: 1.0)
                ],
                symbols: ["speaker.wave.2.fill", "sparkles", "circle.fill", "heart.fill"]
            )

            VStack(spacing: 16) {
                HStack {
                    MascotView(emoji: mode.mascotEmoji, message: "Nghe rồi chọn nhé")
                    Spacer()
                    StickerRewardView(count: stickerRewardCount)
                }

                LearningCardView(backgroundColor: .white.opacity(0.58)) {
                    Text("Nghe và chọn")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(.primary)

                    AudioReplayButton {
                        replayQuestion()
                    }

                    optionPlayArea

                    FeedbackOverlayView(
                        text: viewModel.feedbackText,
                        isCorrect: viewModel.feedbackState == .correct,
                        isWrong: viewModel.feedbackState == .wrong
                    )
                }
            }
            .padding(16)

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
            GiftRewardPopupView(isVisible: showGiftReward, stickerCount: stickerRewardCount)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton()
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateEnabledLetters(enabledAlphabetCharacters)
            viewModel.updateMaxNumberValue(maxNumberValue)
            isFloating = true
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

    private var optionPlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    BubbleButtonView(
                        color: colors[index % colors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        isHinted: viewModel.shouldHighlightOption(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: isFloating,
                        delay: Double(index) * 0.14
                    ) {
                        selectValue(option.value)
                    } content: {
                        Text(option.value)
                            .font(.system(size: mode == .alphabet ? 70 : 64, weight: .black))
                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.36))
                            .shadow(color: .white.opacity(0.75), radius: 1.5, x: 0, y: 1)
                    }
                    .frame(width: bubbleSize(in: geometry.size), height: bubbleSize(in: geometry.size))
                    .position(x: geometry.size.width * option.xRatio, y: geometry.size.height * option.yRatio)
                    .opacity(viewModel.shouldShowOption(option) ? 1 : 0)
                    .disabled(viewModel.feedbackState == .correct || viewModel.isInputLocked || !viewModel.shouldShowOption(option))
                }
            }
        }
        .frame(height: 330)
    }

    private func bubbleSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.30, 108), 142)
    }

    private func isCorrect(_ option: ListenAndPickOption) -> Bool {
        viewModel.feedbackState == .correct && viewModel.selectedValue == option.value
    }

    private func isWrong(_ option: ListenAndPickOption) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedValue == option.value
    }

    private func selectValue(_ value: String) {
        nextRoundTask?.cancel()
        viewModel.selectValue(value)

        guard viewModel.feedbackState == .correct else {
            audioService.speak(viewModel.responseSpeechText, language: viewModel.language.speechCode)
            nextRoundTask = Task {
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { return }
                viewModel.unlockInput()
            }
            return
        }

        stickerRewardCount += 1
        showGiftIfNeeded()
        nextRoundTask = Task {
            async let minimumWait: Void = waitBeforeNextRound()
            await audioService.speakAndWait(viewModel.responseSpeechText, language: viewModel.language.speechCode)
            await minimumWait
            guard !Task.isCancelled else { return }
            viewModel.generateNewRound()
            audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
        }
    }

    private func replayQuestion() {
        audioService.speak(viewModel.promptSpeechText, language: viewModel.language.speechCode)
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
        ListenAndPickGameView(mode: .alphabet)
    }
}
