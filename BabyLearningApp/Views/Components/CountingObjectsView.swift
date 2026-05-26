import SwiftUI

struct CountingObjectsView: View {
    let leftCount: Int
    let rightCount: Int
    let emoji: String
    let roundID: UUID
    let isFloating: Bool
    var isHighlighted = false
    var objectSize: CGFloat?

    var body: some View {
        HStack(spacing: 12) {
            objectGroup(count: leftCount, side: "left", seed: 0)
            objectGroup(count: rightCount, side: "right", seed: 7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .padding(isHighlighted ? 4 : 0)
        .background(isHighlighted ? Color.yellow.opacity(0.18) : Color.clear, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(isHighlighted ? .yellow.opacity(0.85) : .clear, lineWidth: 4)
        }
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isHighlighted)
    }

    private func objectGroup(count: Int, side: String, seed: Int) -> some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let position = position(for: index, count: count, size: geometry.size, seed: seed)
                    let resolvedSize = resolvedObjectSize(count: count, in: geometry.size)

                    FloatingObjectView(
                        emoji: emoji,
                        rotation: rotation(for: index + seed),
                        xOffset: 0,
                        yOffset: 0,
                        isFloating: isFloating,
                        delay: Double(index) * 0.08,
                        size: resolvedSize
                    )
                    .id("\(roundID.uuidString)-\(side)-\(index)")
                    .position(position)
                }
            }
        }
        .frame(maxWidth: .infinity)
            .frame(height: 240)
        .background(.white.opacity(0.38), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func position(for index: Int, count: Int, size: CGSize, seed: Int) -> CGPoint {
        let columns = columnCount(for: count)
        let rows = max(1, Int(ceil(Double(count) / Double(columns))))
        let row = index / columns
        let column = index % columns
        let x = size.width * (CGFloat(column) + 0.5) / CGFloat(columns)
        let y = size.height * (CGFloat(row) + 0.5) / CGFloat(rows)
        let wobbleX = CGFloat(((index + seed) % 3) - 1) * 4
        let wobbleY = CGFloat(((index + seed + 1) % 3) - 1) * 4

        return CGPoint(x: x + wobbleX, y: y + wobbleY)
    }

    private func columnCount(for count: Int) -> Int {
        switch count {
        case 1:
            return 1
        case 2...4:
            return 2
        case 5...6:
            return 3
        default:
            return 4
        }
    }

    private func rotation(for index: Int) -> Double {
        [-12, 8, -5, 14, -9][index % 5]
    }

    private func resolvedObjectSize(count: Int, in size: CGSize) -> CGFloat {
        if let objectSize {
            return objectSize
        }

        let columns = columnCount(for: count)
        let rows = max(1, Int(ceil(Double(count) / Double(columns))))
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = size.height / CGFloat(rows)
        let availableCellSize = min(cellWidth, cellHeight)

        return min(max(availableCellSize * 0.72, 46), 78)
    }
}

#Preview {
    CountingObjectsView(leftCount: 2, rightCount: 3, emoji: "🍎", roundID: UUID(), isFloating: true)
        .padding()
}
