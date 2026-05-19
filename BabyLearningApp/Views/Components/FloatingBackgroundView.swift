import SwiftUI

struct FloatingBackgroundView: View {
    let colors: [Color]
    let symbols: [String]
    @State private var isFloating = false

    init(
        colors: [Color] = [
            Color(red: 1.0, green: 0.94, blue: 0.97),
            Color(red: 0.90, green: 0.98, blue: 1.0),
            Color(red: 1.0, green: 0.97, blue: 0.86)
        ],
        symbols: [String] = ["star.fill", "sparkles", "circle.fill", "heart.fill"]
    ) {
        self.colors = colors
        self.symbols = symbols
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            GeometryReader { geometry in
                ForEach(Array(symbols.enumerated()), id: \.offset) { index, symbol in
                    Image(systemName: symbol)
                        .font(.system(size: symbolSize(for: index), weight: .bold))
                        .foregroundStyle(symbolColor(for: index))
                        .position(
                            x: geometry.size.width * xRatio(for: index),
                            y: geometry.size.height * yRatio(for: index) + (isFloating ? -8 : 8)
                        )
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(Double(index) * 0.18), value: isFloating)
                }
            }
        }
        .onAppear {
            isFloating = true
        }
    }

    private func xRatio(for index: Int) -> CGFloat {
        [0.12, 0.86, 0.18, 0.78, 0.50][index % 5]
    }

    private func yRatio(for index: Int) -> CGFloat {
        [0.16, 0.24, 0.72, 0.64, 0.12][index % 5]
    }

    private func symbolSize(for index: Int) -> CGFloat {
        [22, 28, 18, 24, 20][index % 5]
    }

    private func symbolColor(for index: Int) -> Color {
        [.pink.opacity(0.24), .orange.opacity(0.28), .teal.opacity(0.20), .purple.opacity(0.22)][index % 4]
    }
}

#Preview {
    FloatingBackgroundView()
}
