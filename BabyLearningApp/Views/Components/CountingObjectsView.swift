import SwiftUI

struct CountingObjectsView: View {
    let leftCount: Int
    let rightCount: Int
    let emoji: String
    let roundID: UUID
    let isFloating: Bool

    var body: some View {
        HStack(spacing: 14) {
            objectGroup(count: leftCount, side: "left", seed: 0)
            objectGroup(count: rightCount, side: "right", seed: 7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 155)
    }

    private func objectGroup(count: Int, side: String, seed: Int) -> some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let position = position(for: index, count: count, size: geometry.size, seed: seed)

                    FloatingObjectView(
                        emoji: emoji,
                        rotation: rotation(for: index + seed),
                        xOffset: 0,
                        yOffset: 0,
                        isFloating: isFloating,
                        delay: Double(index) * 0.08
                    )
                    .id("\(roundID.uuidString)-\(side)-\(index)")
                    .position(position)
                }
            }
        }
        .frame(maxWidth: .infinity)
            .frame(height: 145)
        .background(.white.opacity(0.38), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func position(for index: Int, count: Int, size: CGSize, seed: Int) -> CGPoint {
        let layouts: [[(CGFloat, CGFloat)]] = [
            [(0.50, 0.50)],
            [(0.36, 0.42), (0.64, 0.62)],
            [(0.30, 0.36), (0.62, 0.30), (0.50, 0.70)],
            [(0.26, 0.34), (0.68, 0.32), (0.36, 0.70), (0.74, 0.66)],
            [(0.24, 0.30), (0.56, 0.28), (0.76, 0.52), (0.34, 0.68), (0.62, 0.76)]
        ]
        let layout = layouts[min(max(count, 1), 5) - 1]
        let ratio = layout[index % layout.count]
        let wobbleX = CGFloat(((index + seed) % 3) - 1) * 5
        let wobbleY = CGFloat(((index + seed + 1) % 3) - 1) * 5

        return CGPoint(x: size.width * ratio.0 + wobbleX, y: size.height * ratio.1 + wobbleY)
    }

    private func rotation(for index: Int) -> Double {
        [-12, 8, -5, 14, -9][index % 5]
    }
}

#Preview {
    CountingObjectsView(leftCount: 2, rightCount: 3, emoji: "🍎", roundID: UUID(), isFloating: true)
        .padding()
}
