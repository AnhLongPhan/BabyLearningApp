import SwiftUI

struct AnswerBubbleView: View {
    let value: Int
    let color: Color
    let isCorrect: Bool
    let isWrong: Bool
    let isHinted: Bool
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
                            .stroke(isHinted ? .yellow.opacity(0.95) : .white.opacity(0.86), lineWidth: isHinted ? 8 : 5)
                    }
                    .shadow(color: isHinted ? .yellow.opacity(0.55) : color.opacity(0.28), radius: isHinted ? 18 : 13, y: 8)

                Text("\(value)")
                    .font(.system(size: 50, weight: .black))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.36))
                    .minimumScaleFactor(0.55)
                    .shadow(color: .white.opacity(0.75), radius: 1.5, x: 0, y: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isCorrect {
                    VStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.28), radius: 2, y: 1)
                    .padding(12)
                }
            }
            .scaleEffect(isCorrect ? 1.18 : 1.0)
            .offset(y: isFloating ? -8 : 8)
            .modifier(AnswerBubbleShakeEffect(shakes: isWrong ? CGFloat(wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.16).repeatForever(autoreverses: true).delay(delay), value: isFloating)
            .animation(.spring(response: 0.28, dampingFraction: 0.5), value: isCorrect)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isHinted)
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
    AnswerBubbleView(value: 6, color: .pink, isCorrect: true, isWrong: false, isHinted: false, wrongAttemptCount: 0, isFloating: true, delay: 0) {}
        .frame(width: 130, height: 130)
        .padding()
}
