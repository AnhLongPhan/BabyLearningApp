import SwiftUI

struct MathGameView: View {
    @AppStorage("totalCorrectMathAnswers") private var savedTotalCorrectAnswers = 0
    @AppStorage("maxMathSum") private var maxMathSum = 5
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = ""
    @State private var viewModel = MathGameViewModel()
    @State private var audioService = AudioService()
    @State private var isFloating = false
    @State private var nextRoundTask: Task<Void, Never>?

    private let answerColors: [Color] = [.pink, .teal, .orange]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

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
                VStack(spacing: 14) {
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
                        isFloating: isFloating
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
                .padding(.bottom, 84)
            }

            HandHintView(answer: viewModel.correctAnswer)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .opacity(0.88)

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
        }
        .navigationTitle("Cộng đơn giản")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateMaxMathSum(maxMathSum)
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
        .onChange(of: childName) { _, newValue in
            viewModel.updateChildName(newValue)
        }
        .onDisappear {
            nextRoundTask?.cancel()
            audioService.stop()
        }
    }

    private var equationCloud: some View {
        VStack(spacing: 12) {
            Text("\(viewModel.leftNumber) + \(viewModel.rightNumber) = ?")
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(.pink)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            AudioReplayButton {
                replayQuestion()
            }
            .scaleEffect(0.82)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 14)
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
                    .disabled(viewModel.feedbackState == .correct)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 220)
        }
        .frame(height: 230)
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
        min(max(size.width * 0.26, 96), 124)
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
