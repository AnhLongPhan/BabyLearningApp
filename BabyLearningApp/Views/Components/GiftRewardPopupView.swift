import SwiftUI

struct GiftRewardPopupView: View {
    let isVisible: Bool
    let stickerCount: Int

    var body: some View {
        if isVisible {
            VStack(spacing: 10) {
                Text("🎁")
                    .font(.system(size: 58))
                    .scaleEffect(isVisible ? 1.08 : 0.8)

                Text("Mở khóa sticker mới!")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Bộ sưu tập: \(StickerCatalog.unlockedCount(for: stickerCount))/\(StickerCatalog.stickers.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(.purple.gradient, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 3)
            }
            .shadow(color: .purple.opacity(0.28), radius: 18, y: 10)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.34, dampingFraction: 0.62), value: isVisible)
            .overlay {
                ConfettiBurstView(isActive: isVisible)
            }
        }
    }
}

#Preview {
    GiftRewardPopupView(isVisible: true, stickerCount: 10)
        .padding()
}
