import Foundation

enum MathObjectTheme: String, CaseIterable, Identifiable {
    case apple
    case banana
    case worm
    case star
    case balloon
    case fish
    case flower
    case car
    case bus
    case train
    case airplane
    case bicycle
    case person
    case baby
    case tree
    case leaf

    var id: String { rawValue }

    var name: String {
        switch self {
        case .apple:
            return "Táo"
        case .banana:
            return "Chuối"
        case .worm:
            return "Sâu"
        case .star:
            return "Sao"
        case .balloon:
            return "Bóng bay"
        case .fish:
            return "Cá"
        case .flower:
            return "Hoa"
        case .car:
            return "Ô tô"
        case .bus:
            return "Xe buýt"
        case .train:
            return "Tàu hoả"
        case .airplane:
            return "Máy bay"
        case .bicycle:
            return "Xe đạp"
        case .person:
            return "Người"
        case .baby:
            return "Em bé"
        case .tree:
            return "Cây"
        case .leaf:
            return "Lá cây"
        }
    }

    static var defaultStorageValue: String {
        allCases.map(\.rawValue).joined(separator: ",")
    }

    static func themes(from storageValue: String) -> [MathObjectTheme] {
        let selectedIDs = Set(storageValue.split(separator: ",").map(String.init))
        let selectedThemes = allCases.filter { selectedIDs.contains($0.rawValue) }
        return selectedThemes.isEmpty ? allCases : selectedThemes
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
        case .car:
            return "🚗"
        case .bus:
            return "🚌"
        case .train:
            return "🚂"
        case .airplane:
            return "✈️"
        case .bicycle:
            return "🚲"
        case .person:
            return "🧍"
        case .baby:
            return "👶"
        case .tree:
            return "🌳"
        case .leaf:
            return "🍃"
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
        case .car:
            return "chiếc ô tô"
        case .bus:
            return "chiếc xe buýt"
        case .train:
            return "chiếc tàu hoả"
        case .airplane:
            return "chiếc máy bay"
        case .bicycle:
            return "chiếc xe đạp"
        case .person:
            return "người"
        case .baby:
            return "em bé"
        case .tree:
            return "cái cây"
        case .leaf:
            return "chiếc lá"
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
            case .car:
                return "cars"
            case .bus:
                return "buses"
            case .train:
                return "trains"
            case .airplane:
                return "airplanes"
            case .bicycle:
                return "bicycles"
            case .person:
                return "people"
            case .baby:
                return "babies"
            case .tree:
                return "trees"
            case .leaf:
                return "leaves"
            }
        }
    }
}
