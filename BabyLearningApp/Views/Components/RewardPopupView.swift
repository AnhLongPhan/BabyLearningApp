import SwiftUI

struct RewardPopupView: View {
    let text: String
    let isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(text)
                    Image(systemName: "star.fill")
                }
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(.white)

                Text("+1")
                    .font(.title2.bold())
                    .foregroundStyle(.yellow)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(.pink.gradient, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .pink.opacity(0.28), radius: 18, y: 10)
            .transition(.scale.combined(with: .opacity))
            .overlay {
                ConfettiBurstView(isActive: isVisible)
            }
        }
    }
}

#Preview {
    RewardPopupView(text: "Giỏi quá!", isVisible: true)
        .padding()
}
