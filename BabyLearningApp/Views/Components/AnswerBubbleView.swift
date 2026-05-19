import SwiftUI

struct AnswerBubbleView: View {
    let value: Int
    let color: Color
    let isCorrect: Bool
    let isWrong: Bool
    let wrongAttemptCount: Int
    let isFloating: Bool
    let delay: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(color.gradient)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.86), lineWidth: 5)
                    }
                    .shadow(color: color.opacity(0.28), radius: 13, y: 8)

                Text("\(value)")
                    .font(.system(size: 62, weight: .black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isCorrect {
                    VStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(12)
                }
            }
            .scaleEffect(isCorrect ? 1.18 : 1.0)
            .offset(y: isFloating ? -8 : 8)
            .modifier(AnswerBubbleShakeEffect(shakes: isWrong ? CGFloat(wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.16).repeatForever(autoreverses: true).delay(delay), value: isFloating)
            .animation(.spring(response: 0.28, dampingFraction: 0.5), value: isCorrect)
            .animation(.default, value: wrongAttemptCount)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Đáp án \(value)")
    }
}

private struct AnswerBubbleShakeEffect: GeometryEffect {
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
    AnswerBubbleView(value: 6, color: .pink, isCorrect: true, isWrong: false, wrongAttemptCount: 0, isFloating: true, delay: 0) {}
        .frame(width: 130, height: 130)
        .padding()
}
