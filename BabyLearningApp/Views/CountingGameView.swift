import SwiftUI

struct CountingGameView: View {
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = ""
    @State private var viewModel = CountingGameViewModel()
    @State private var audioService = AudioService()
    @State private var isFloating = false
    @State private var nextRoundTask: Task<Void, Never>?

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
                VStack(spacing: 14) {
                    HStack {
                        MascotView(emoji: "🐰", message: countingMascotMessage)
                        Spacer()
                        StickerRewardView(count: stickerRewardCount)
                    }

                    VStack(spacing: 12) {
                        Text("Có bao nhiêu?")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(.teal)

                        AudioReplayButton {
                            replayQuestion()
                        }
                        .scaleEffect(0.88)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

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
        }
        .navigationTitle("Đếm đồ vật")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateMaxCount(maxNumberValue)
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
                        delay: Double(index) * 0.06
                    )
                    .position(position)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 210)
            .background(.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .frame(height: 220)
    }

    private var answerPlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element.id) { index, option in
                    BubbleButtonView(
                        color: bubbleColors[index % bubbleColors.count],
                        isCorrect: isCorrect(option),
                        isWrong: isWrong(option),
                        wrongAttemptCount: viewModel.wrongAttemptCount,
                        isFloating: isFloating,
                        delay: Double(index) * 0.14
                    ) {
                        selectAnswer(option.value)
                    } content: {
                        Text("\(option.value)")
                            .font(.system(size: 62, weight: .black))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.55)
                    }
                    .frame(width: answerBubbleSize(in: geometry.size), height: answerBubbleSize(in: geometry.size))
                    .position(
                        x: geometry.size.width * option.xRatio,
                        y: geometry.size.height * option.yRatio
                    )
                    .disabled(viewModel.feedbackState == .correct)
                }
            }
        }
        .frame(height: 220)
    }

    private func objectPosition(index: Int, count: Int, size: CGSize) -> CGPoint {
        let columns = min(5, max(1, count))
        let row = index / columns
        let column = index % columns
        let x = size.width * (CGFloat(column) + 0.75) / CGFloat(columns + 1)
        let y = size.height * (CGFloat(row) + 0.78) / CGFloat(max(2, (count + columns - 1) / columns) + 1)
        let wobbleX = CGFloat((index % 3) - 1) * 10
        let wobbleY = CGFloat(((index + 1) % 3) - 1) * 8
        return CGPoint(x: x + wobbleX, y: y + wobbleY)
    }

    private func objectRotation(_ index: Int) -> Double {
        [-12, 8, -4, 13, -7][index % 5]
    }

    private func answerBubbleSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.28, 96), 122)
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
            return
        }

        stickerRewardCount += 1
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
}

#Preview {
    NavigationStack {
        CountingGameView()
    }
}
