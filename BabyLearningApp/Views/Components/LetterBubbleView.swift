import SwiftUI

struct LetterBubbleView: View {
    let letter: String
    let color: Color
    let isCorrect: Bool
    let isWrong: Bool
    let isHinted: Bool
    let isExploring: Bool
    let isPopped: Bool
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
                            .stroke(isHinted ? .yellow.opacity(0.95) : .white.opacity(0.82), lineWidth: isHinted ? 8 : 5)
                    }
                    .shadow(color: isHinted ? .yellow.opacity(0.55) : color.opacity(0.25), radius: isHinted ? 18 : 14, y: 8)

                Text(letter)
                    .font(.system(size: 82, weight: .black))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.36))
                    .minimumScaleFactor(0.55)
                    .shadow(color: .white.opacity(0.75), radius: 1.5, x: 0, y: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isCorrect {
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.28), radius: 2, y: 1)
                    .padding(14)
                }
            }
            .scaleEffect(isPopped ? 1.28 : (isCorrect ? 1.16 : (isExploring ? 1.10 : 1.0)))
            .opacity(isPopped ? 0.15 : 1.0)
            .rotationEffect(.degrees(isExploring ? 5 : 0))
            .offset(y: isFloating ? -8 : 8)
            .modifier(LetterBubbleShakeEffect(shakes: isWrong ? CGFloat(wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true).delay(animationDelay), value: isFloating)
            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: isCorrect)
            .animation(.spring(response: 0.22, dampingFraction: 0.45), value: isExploring)
            .animation(.easeOut(duration: 0.35), value: isPopped)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isHinted)
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
        isHinted: false,
        isExploring: false,
        isPopped: false,
        wrongAttemptCount: 0,
        isFloating: true,
        animationDelay: 0
    ) {}
    .frame(width: 150, height: 150)
    .padding()
}
