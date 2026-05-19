import Foundation

enum MathObjectTheme: String, CaseIterable, Identifiable {
    case apple
    case banana
    case worm
    case star
    case balloon
    case fish
    case flower

    var id: String { rawValue }

    var name: String {
        rawValue
    }

    var emoji: String {
        switch self {
        case .apple:
            return "🍎"
        case .banana:
            return "🍌"
        case .worm:
            return "🐛"
        case .star:
            return "⭐"
        case .balloon:
            return "🎈"
        case .fish:
            return "🐟"
        case .flower:
            return "🌸"
        }
    }

    var speechName: String {
        switch self {
        case .apple:
            return "quả táo"
        case .banana:
            return "quả chuối"
        case .worm:
            return "con sâu"
        case .star:
            return "ngôi sao"
        case .balloon:
            return "quả bóng bay"
        case .fish:
            return "con cá"
        case .flower:
            return "bông hoa"
        }
    }

    func speechName(for language: LearningLanguage) -> String {
        switch language {
        case .vietnamese:
            return speechName
        case .english:
            switch self {
            case .apple:
                return "apples"
            case .banana:
                return "bananas"
            case .worm:
                return "worms"
            case .star:
                return "stars"
            case .balloon:
                return "balloons"
            case .fish:
                return "fish"
            case .flower:
                return "flowers"
            }
        }
    }
}
