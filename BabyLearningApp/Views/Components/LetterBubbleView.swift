import SwiftUI

struct LetterBubbleView: View {
    let letter: String
    let color: Color
    let isCorrect: Bool
    let isWrong: Bool
    let wrongAttemptCount: Int
    let isFloating: Bool
    let animationDelay: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(color.gradient)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.82), lineWidth: 5)
                    }
                    .shadow(color: color.opacity(0.25), radius: 14, y: 8)

                Text(letter)
                    .font(.system(size: 82, weight: .black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isCorrect {
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(14)
                }
            }
            .scaleEffect(isCorrect ? 1.16 : 1.0)
            .offset(y: isFloating ? -8 : 8)
            .modifier(LetterBubbleShakeEffect(shakes: isWrong ? CGFloat(wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true).delay(animationDelay), value: isFloating)
            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: isCorrect)
            .animation(.default, value: wrongAttemptCount)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Chữ \(letter)")
    }
}

private struct LetterBubbleShakeEffect: GeometryEffect {
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
    LetterBubbleView(
        letter: "A",
        color: .orange,
        isCorrect: true,
        isWrong: false,
        wrongAttemptCount: 0,
        isFloating: true,
        animationDelay: 0
    ) {}
    .frame(width: 150, height: 150)
    .padding()
}
