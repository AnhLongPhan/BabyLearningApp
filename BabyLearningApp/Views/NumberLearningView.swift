import SwiftUI

struct NumberLearningView: View {
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = ""
    @State private var viewModel = NumberGameViewModel()
    @State private var audioService = AudioService()
    @State private var floatingCards = false
    @State private var nextRoundTask: Task<Void, Never>?

    private let cardStyles: [NumberCardStyle] = [
        NumberCardStyle(fruit: "🍎", color: .red, xRatio: 0.24, yRatio: 0.32, rotation: -8),
        NumberCardStyle(fruit: "🍊", color: .orange, xRatio: 0.76, yRatio: 0.34, rotation: 7),
        NumberCardStyle(fruit: "🍌", color: .yellow, xRatio: 0.50, yRatio: 0.72, rotation: -3)
    ]
    private let minimumCorrectFeedbackDuration: Duration = .seconds(3)

    var body: some View {
        ZStack {
            FloatingBackgroundView(
                colors: [
                    Color(red: 0.90, green: 0.99, blue: 1.0),
                    Color(red: 1.0, green: 0.96, blue: 0.88),
                    Color(red: 0.95, green: 0.94, blue: 1.0)
                ],
                symbols: ["circle.fill", "sparkles", "star.fill", "heart.fill"]
            )

            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        MascotView(emoji: "🐵", message: "Tìm số nào")
                        Spacer()
                        StickerRewardView(count: stickerRewardCount)
                    }

                    LearningCardView(backgroundColor: .teal.opacity(0.18)) {
                        Text("Đâu là số \(viewModel.targetNumber)?")
                            .font(.system(size: 36, weight: .black))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.75)

                        AudioReplayButton {
                            replayQuestion()
                        }

                        numberPlayArea

                        feedbackView
                    }
                }
                .padding(16)
            }

            RewardPopupView(text: viewModel.feedbackText, isVisible: viewModel.feedbackState == .correct)
        }
        .navigationTitle("Học số")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateChildName(childName)
            viewModel.updateLanguage(speechLanguageCode)
            viewModel.updateMaxNumberValue(maxNumberValue)
            floatingCards = true
            audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
        }
        .onChange(of: maxNumberValue) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateMaxNumberValue(newValue)
            audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
        }
        .onChange(of: speechLanguageCode) { _, newValue in
            nextRoundTask?.cancel()
            viewModel.updateLanguage(newValue)
            audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
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

    private var numberPlayArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.options.enumerated()), id: \.element) { index, number in
                    let style = cardStyles[index % cardStyles.count]

                    numberOptionCard(number, style: style, index: index)
                        .frame(width: optionSize(in: geometry.size), height: optionSize(in: geometry.size))
                        .position(
                            x: geometry.size.width * style.xRatio,
                            y: geometry.size.height * style.yRatio
                        )
                }
            }
            .frame(maxWidth: .infinity, minHeight: 320)
        }
        .frame(height: 330)
    }

    private func optionSize(in size: CGSize) -> CGFloat {
        min(max(size.width * 0.30, 108), 142)
    }

    private func numberOptionCard(_ number: Int, style: NumberCardStyle, index: Int) -> some View {
        Button {
            selectNumber(number)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(style.color.gradient)
                    .overlay {
                        Text(style.fruit)
                            .font(.system(size: 78))
                            .opacity(0.28)
                            .offset(x: -18, y: -22)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(.white.opacity(0.82), lineWidth: 5)
                    }
                    .shadow(color: style.color.opacity(0.3), radius: 12, y: 8)

                Text("\(number)")
                    .font(.system(size: 82, weight: .black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if viewModel.feedbackState == .correct && viewModel.selectedNumber == number {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                }
            }
            .scaleEffect(viewModel.feedbackState == .correct && viewModel.selectedNumber == number ? 1.12 : 1.0)
            .offset(y: floatingCards ? -6 : 6)
            .rotationEffect(.degrees(style.rotation))
            .modifier(ShakeEffect(shakes: shouldShake(number) ? CGFloat(viewModel.wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(Double(index) * 0.12), value: floatingCards)
            .animation(.spring(response: 0.28, dampingFraction: 0.5), value: viewModel.feedbackState)
            .animation(.default, value: viewModel.wrongAttemptCount)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.feedbackState == .correct)
        .accessibilityLabel("Số \(number)")
    }

    private func shouldShake(_ number: Int) -> Bool {
        viewModel.feedbackState == .wrong && viewModel.selectedNumber == number
    }

    private func selectNumber(_ number: Int) {
        nextRoundTask?.cancel()
        viewModel.selectNumber(number)

        guard viewModel.feedbackState == .correct else {
            audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
            return
        }

        stickerRewardCount += 1
        nextRoundTask = Task {
            async let minimumWait: Void = waitBeforeNextRound()
            await audioService.speakAndWait(viewModel.speechText, language: viewModel.language.speechCode)
            await minimumWait
            guard !Task.isCancelled else { return }
            viewModel.generateNewRound()
            audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
        }
    }

    private func replayQuestion() {
        audioService.speak(viewModel.speechText, language: viewModel.language.speechCode)
    }

    private func waitBeforeNextRound() async {
        try? await Task.sleep(for: minimumCorrectFeedbackDuration)
    }
}

private struct NumberCardStyle {
    let fruit: String
    let color: Color
    let xRatio: CGFloat
    let yRatio: CGFloat
    let rotation: Double
}

private struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 9, y: 0))
    }
}

#Preview {
    NavigationStack {
        NumberLearningView()
    }
}
