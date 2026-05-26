import SwiftUI

struct MathGameView: View {
    let showsBackButton: Bool

    @AppStorage("totalCorrectMathAnswers") private var savedTotalCorrectAnswers = 0
    @AppStorage("maxMathSum") private var maxMathSum = 5
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = "Bé"
    @AppStorage("enabledMathObjectThemes") private var enabledMathObjectThemes = MathObjectTheme.defaultStorageValue
    @State private var viewModel = MathGameViewModel()
    @State private var audioService = AudioService()
    @State private var isFloating = false
    @State private var nextRoundTask: Task<Void, Never>?
    @State private var showGiftReward = false

    private let answerColors: [Color] = [.pink, .teal, .orange]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    init(showsBackButton: Bool = true) {
        self.showsBackButton = showsBackButton
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.94, blue: 0.97),
                    Color(red: 0.90, green: 0.98, blue: 1.0),
                    Color(red: 1.0, green: 0.97, blue: 0.86)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        MascotView(emoji: "🐼", message: "Cộng vui nào")
                        Spacer()
                        StickerRewardView(count: stickerRewardCount)
                    }

                    equationCloud

                    CountingObjectsView(
                        leftCount: viewModel.leftNumber,
                        rightCount: viewModel.rightNumber,
                        emoji: viewModel.objectEmoji,
                        roundID: viewModel.roundID,
                        isFloating: isFloating,
                        isHighlighted: viewModel.hintLevel >= 2
                    )
                    .id(viewModel.roundID)
                    .padding(.horizontal, 2)

                    answerPlayArea

                    FeedbackOverlayView(
                        text: viewModel.feedbackText,
                        isCorrect: viewModel.feedbackState == .correct,
                        isWrong: viewModel.feedbackState == .wrong
                    )

                    Text("Đúng: \(viewModel.totalCorrectAnswers)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .padding(.bottom, 56)
            }

            HandHintView(answer: viewModel.correctAnswer)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .opacity(0.88)

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
            GiftRewardPopupView(isVisible: showGiftReward, stickerCount: stickerRewardCount)
        }
        .navigationTitle("Cộng đơn giản")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton(showsBackButton)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateMaxMathSum(maxMathSum)
            viewModel.updateEnabledThemes(enabledMathObjectThemes)
            viewModel.updateTotalCorrectAnswers(savedTotalCorrectAnswers)
            isFloating = true
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: maxMathSum) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateMaxMathSum(newValue)
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: speechLanguageCode) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateLanguage(newValue)
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: enabledMathObjectThemes) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateEnabledThemes(newValue)
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: childName) { _, newValue in
            viewModel.updateChildName(newValue)
        }
        .onDisappear {
            nextRoundTask?.cancel()
            audioService.stop()
        }
    }

    private var equationCloud: some View {
        HStack(spacing: 12) {
            Text("\(viewModel.leftNumber) + \(viewModel.rightNumber) = ?")
                .font(.system(size: 40, weight: .black))
                .foregroundStyle(.pink)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            AudioReplayButton(isCompact: true) {
                replayQuestion()
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background {
            CloudCardShape()
                .fill(.white.opacity(0.88))
                .shadow(color: .pink.opacity(0.16), radius: 14, y: 8)
        }
    }

    private var answerPlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    AnswerBubbleView(
                        value: option.value,
                        color: answerColors[index % answerColors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        isHinted: viewModel.shouldHighlightOption(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: isFloating,
                        delay: Double(index) * 0.14
                    ) {
                        selectAnswer(option.value)
                    }
                    .frame(width: answerBubbleSize(in: geometry.size), height: answerBubbleSize(in: geometry.size))
                    .position(
                        x: geometry.size.width * option.xRatio,
                        y: geometry.size.height * option.yRatio
                    )
                    .opacity(viewModel.shouldShowOption(option) ? 1 : 0)
                    .disabled(viewModel.feedbackState == .correct || viewModel.isInputLocked || !viewModel.shouldShowOption(option))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 125)
        }
        .frame(height: 135)
    }

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.28))
                .frame(width: 92, height: 92)
                .offset(x: -142, y: -270)

            Circle()
                .fill(.yellow.opacity(0.24))
                .frame(width: 72, height: 72)
                .offset(x: 134, y: -214)

            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.pink.opacity(0.35))
                .offset(x: -132, y: 176)

            Image(systemName: "star.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.orange.opacity(0.30))
                .offset(x: 130, y: 116)
        }
    }

    private func answerBubbleSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.20, 76), 92)
    }

    private func isCorrect(_ option: MathAnswerOption) -> Bool {
        viewModel.feedbackState == .correct && viewModel.selectedAnswer == option.value
    }

    private func isWrong(_ option: MathAnswerOption) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedAnswer == option.value
    }

    private func selectAnswer(_ answer: Int) {
        nextRoundTask?.cancel()
        viewModel.selectAnswer(answer)

        switch viewModel.feedbackState {
        case .correct:
            savedTotalCorrectAnswers = viewModel.totalCorrectAnswers
            stickerRewardCount += 1
            showGiftIfNeeded()
            nextRoundTask = Task {
                async let minimumWait: Void = waitBeforeNextRound()
                await audioService.speakAndWait(viewModel.responseSpeechText, language: viewModel.language.speechCode)
                await minimumWait
                guard !Task.isCancelled else { return }
                viewModel.generateNewRound()
                audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
            }
        case .wrong:
            audioService.speak(viewModel.responseSpeechText, language: viewModel.language.speechCode)
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
        audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
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

private struct CloudCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.height * 0.38, 34)
        return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
    }
}

#Preview {
    NavigationStack {
        MathGameView()
    }
}
