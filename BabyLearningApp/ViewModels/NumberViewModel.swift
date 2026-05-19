import Foundation
import Observation

@MainActor
@Observable
final class NumberViewModel {
    let items: [NumberItem]

    private(set) var currentIndex: Int

    var currentItem: NumberItem {
        items[currentIndex]
    }

    init(items: [NumberItem] = SampleLearningData.numberItems, currentIndex: Int = 0) {
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

    private static func validIndex(_ index: Int, itemCount: Int) -> Int {
        guard itemCount > 0 else { return 0 }
        return min(max(index, 0), itemCount - 1)
    }
}
