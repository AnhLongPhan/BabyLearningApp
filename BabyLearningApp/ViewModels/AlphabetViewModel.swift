import Foundation
import Observation

@MainActor
@Observable
final class AlphabetViewModel {
    private let allItems: [AlphabetItem]
    private(set) var items: [AlphabetItem]

    private(set) var currentIndex: Int

    var currentItem: AlphabetItem {
        items[currentIndex]
    }

    init(items: [AlphabetItem] = SampleLearningData.alphabetItems, currentIndex: Int = 0) {
        self.allItems = items
        self.items = items
        self.currentIndex = Self.validIndex(currentIndex, itemCount: items.count)
    }

    func moveToNextItem() {
        guard !items.isEmpty else { return }
        currentIndex = (currentIndex + 1) % items.count
    }

    func updateCurrentIndex(_ index: Int) {
        currentIndex = Self.validIndex(index, itemCount: items.count)
    }

    func updateEnabledLetters(_ letters: String) {
        let enabledLetters = Set(letters.uppercased().map(String.init))
        let filteredItems = allItems.filter { enabledLetters.contains($0.letter.uppercased()) }
        items = filteredItems.isEmpty ? allItems : filteredItems
        currentIndex = Self.validIndex(currentIndex, itemCount: items.count)
    }

    private static func validIndex(_ index: Int, itemCount: Int) -> Int {
        guard itemCount > 0 else { return 0 }
        return min(max(index, 0), itemCount - 1)
    }
}
