import SwiftUI

struct CountingGameView: View {
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = "Bé"
    @AppStorage("enabledMathObjectThemes") private var enabledMathObjectThemes = MathObjectTheme.defaultStorageValue
    @State private var viewModel = CountingGameViewModel()
    @State private var audioService = AudioService()
    @State private var isFloating = false
    @State private var nextRoundTask: Task<Void, Never>?
    @State private var showGiftReward = false

    private let bubbleColors: [Color] = [.teal, .orange, .pink]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    private var countingMascotMessage: String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Cùng đếm nhé" : "\(trimmedName) cùng đếm nhé"
    }

    var body: some View {
        ZStack {
            FloatingBackgroundView(
                colors: [
                    Color(red: 0.92, green: 0.99, blue: 0.96),
                    Color(red: 1.0, green: 0.96, blue: 0.88),
                    Color(red: 0.96, green: 0.93, blue: 1.0)
                ],
                symbols: ["sparkles", "star.fill", "heart.fill", "circle.fill"]
            )

            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        MascotView(emoji: "🐰", message: countingMascotMessage)
                        Spacer()
                        StickerRewardView(count: stickerRewardCount)
                    }

                    HStack(spacing: 12) {
                        Text("Có bao nhiêu?")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.teal)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        AudioReplayButton(isCompact: true) {
                            replayQuestion()
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                    countingObjectField

                    answerPlayArea

                    FeedbackOverlayView(
                        text: viewModel.feedbackText,
                        isCorrect: viewModel.feedbackState == .correct,
                        isWrong: viewModel.feedbackState == .wrong
                    )
                }
                .padding(16)
            }

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
            GiftRewardPopupView(isVisible: showGiftReward, stickerCount: stickerRewardCount)
        }
        .navigationTitle("Đếm đồ vật")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton()
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateMaxCount(maxNumberValue)
            viewModel.updateEnabledThemes(enabledMathObjectThemes)
            isFloating = true
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
        }
        .onChange(of: maxNumberValue) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateMaxCount(newValue)
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

    private var countingObjectField: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<viewModel.objectCount, id: \.self) { index in
                    let position = objectPosition(index: index, count: viewModel.objectCount, size: geometry.size)

                    FloatingObjectView(
                        emoji: viewModel.objectEmoji,
                        rotation: objectRotation(index),
                        xOffset: 0,
                        yOffset: 0,
                        isFloating: isFloating,
                        delay: Double(index) * 0.06,
                        size: 62
                    )
                    .position(position)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            .background(.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(viewModel.hintLevel >= 2 ? .yellow.opacity(0.85) : .clear, lineWidth: 4)
            }
        }
        .frame(height: 310)
    }

    private var answerPlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    BubbleButtonView(
                        color: bubbleColors[index % bubbleColors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        isHinted: viewModel.shouldHighlightOption(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: isFloating,
                        delay: Double(index) * 0.14
                    ) {
                        selectAnswer(option.value)
                    } content: {
                        Text("\(option.value)")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.36))
                            .minimumScaleFactor(0.55)
                            .shadow(color: .white.opacity(0.75), radius: 1.5, x: 0, y: 1)
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
        }
        .frame(height: 155)
    }

    private func objectPosition(index: Int, count: Int, size: CGSize) -> CGPoint {
        let columns: Int
        switch count {
        case 1:
            columns = 1
        case 2...4:
            columns = 2
        case 5...6:
            columns = 3
        default:
            columns = 4
        }
        let row = index / columns
        let column = index % columns
        let rows = max(1, Int(ceil(Double(count) / Double(columns))))
        let x = size.width * (CGFloat(column) + 0.5) / CGFloat(columns)
        let y = size.height * (CGFloat(row) + 0.5) / CGFloat(rows)
        let wobbleX = CGFloat((index % 3) - 1) * 5
        let wobbleY = CGFloat(((index + 1) % 3) - 1) * 5
        return CGPoint(x: x + wobbleX, y: y + wobbleY)
    }

    private func objectRotation(_ index: Int) -> Double {
        [-12, 8, -4, 13, -7][index % 5]
    }

    private func answerBubbleSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.23, 82), 98)
    }

    private func isCorrect(_ option: CountingAnswerOption) -> Bool {
        viewModel.feedbackState == .correct && viewModel.selectedAnswer == option.value
    }

    private func isWrong(_ option: CountingAnswerOption) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedAnswer == option.value
    }

    private func selectAnswer(_ answer: Int) {
        nextRoundTask?.cancel()
        viewModel.selectAnswer(answer)

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
            audioService.speak(viewModel.questionSpeechText, language: viewModel.language.speechCode)
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

#Preview {
    NavigationStack {
        CountingGameView()
    }
}
