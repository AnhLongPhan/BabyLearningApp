import SwiftUI

struct FeedbackOverlayView: View {
    let text: String
    let isCorrect: Bool
    let isWrong: Bool

    var body: some View {
        HStack(spacing: 10) {
            if isCorrect {
                Image(systemName: "sparkles")
                Image(systemName: "checkmark.circle.fill")
            }

            Text(text)
                .font(.system(size: 30, weight: .black))
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(isCorrect ? .green : .orange)
        .padding(.horizontal, 18)
        .frame(height: 52)
        .background((isCorrect || isWrong) ? Color.white.opacity(0.78) : Color.clear, in: Capsule())
        .scaleEffect(isCorrect ? 1.08 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.55), value: isCorrect)
        .overlay {
            ConfettiBurstView(isActive: isCorrect)
        }
    }
}

#Preview {
    FeedbackOverlayView(text: "Giỏi quá!", isCorrect: true, isWrong: false)
        .padding()
}
