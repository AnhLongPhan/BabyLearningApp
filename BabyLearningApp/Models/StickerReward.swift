import Foundation

struct StickerReward: Identifiable {
    let id: Int
    let emoji: String
    let title: String
    let assetName: String
}

enum StickerCatalog {
    static let stickers: [StickerReward] = [
        StickerReward(id: 1, emoji: "⭐", title: "Ngôi sao", assetName: "sticker_star"),
        StickerReward(id: 2, emoji: "🎁", title: "Hộp quà", assetName: "sticker_gift"),
        StickerReward(id: 3, emoji: "🏆", title: "Cúp vàng", assetName: "sticker_trophy"),
        StickerReward(id: 4, emoji: "🌈", title: "Cầu vồng", assetName: "sticker_rainbow"),
        StickerReward(id: 5, emoji: "🚀", title: "Tên lửa", assetName: "sticker_rocket"),
        StickerReward(id: 6, emoji: "💎", title: "Kim cương", assetName: "sticker_gem"),
        StickerReward(id: 7, emoji: "🎈", title: "Bóng bay", assetName: "sticker_balloon"),
        StickerReward(id: 8, emoji: "🌸", title: "Bông hoa", assetName: "sticker_flower")
    ]

    static func unlockedCount(for correctAnswers: Int) -> Int {
        min(stickers.count, max(0, correctAnswers / 5))
    }
}
