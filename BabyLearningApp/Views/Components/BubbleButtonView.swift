import SwiftUI

struct BubbleButtonView<Content: View>: View {
    let color: Color
    let isCorrect: Bool
    let isWrong: Bool
    let isHinted: Bool
    let wrongAttemptCount: Int
    let isFloating: Bool
    let delay: Double
    let action: () -> Void
    @ViewBuilder let content: Content

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

                content
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
            .modifier(BubbleShakeEffect(shakes: isWrong ? CGFloat(wrongAttemptCount) : 0))
            .animation(.easeInOut(duration: 1.16).repeatForever(autoreverses: true).delay(delay), value: isFloating)
            .animation(.spring(response: 0.28, dampingFraction: 0.5), value: isCorrect)
            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isHinted)
            .animation(.default, value: wrongAttemptCount)
        }
        .buttonStyle(.plain)
    }
}

private struct BubbleShakeEffect: GeometryEffect {
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
    BubbleButtonView(
        color: .pink,
        isCorrect: false,
        isWrong: false,
        isHinted: false,
        wrongAttemptCount: 0,
        isFloating: true,
        delay: 0,
        action: {}
    ) {
        Text("A")
            .font(.system(size: 60, weight: .black))
            .foregroundStyle(.white)
    }
    .frame(width: 130, height: 130)
    .padding()
}
