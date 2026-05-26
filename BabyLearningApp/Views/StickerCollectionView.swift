import SwiftUI
import UIKit

struct StickerCollectionView: View {
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            FloatingBackgroundView(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.88),
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.93, blue: 1.0)
                ],
                symbols: ["star.fill", "sparkles", "gift.fill", "heart.fill"]
            )

            ScrollView {
                VStack(spacing: 18) {
                    MascotView(emoji: "🎁", message: "Bộ sưu tập sticker")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    StickerRewardView(count: stickerRewardCount)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(StickerCatalog.stickers.enumerated()), id: \.element.id) { index, sticker in
                            StickerCardView(
                                sticker: sticker,
                                isUnlocked: index < unlockedCount
                            )
                        }
                    }
                }
                .padding(18)
            }
        }
        .navigationTitle("Sticker")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton()
    }

    private var unlockedCount: Int {
        StickerCatalog.unlockedCount(for: stickerRewardCount)
    }
}

private struct StickerCardView: View {
    let sticker: StickerReward
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            stickerContent
                .frame(width: 70, height: 70)
                .background(.white.opacity(0.76), in: Circle())
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.35)

            Text(isUnlocked ? sticker.title : "Chưa mở")
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 124)
        .padding(8)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isUnlocked ? .yellow.opacity(0.8) : .white.opacity(0.55), lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 5)
    }

    @ViewBuilder
    private var stickerContent: some View {
        if UIImage(named: sticker.assetName) != nil {
            Image(sticker.assetName)
                .resizable()
                .scaledToFit()
        } else {
            Text(sticker.emoji)
                .font(.system(size: 44))
        }
    }
}

#Preview {
    NavigationStack {
        StickerCollectionView()
    }
}
