import SwiftUI

struct ConfettiBurstView: View {
    let isActive: Bool
    @State private var burst = false

    private let colors: [Color] = [.pink, .orange, .yellow, .green, .teal, .purple]

    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: index % 3 == 0 ? 10 : 7, height: index % 3 == 0 ? 10 : 7)
                    .offset(
                        x: burst ? cos(angle(for: index)) * radius(for: index) : 0,
                        y: burst ? sin(angle(for: index)) * radius(for: index) : 0
                    )
                    .opacity(isActive ? (burst ? 0.0 : 1.0) : 0.0)
                    .scaleEffect(burst ? 1.25 : 0.4)
                    .animation(.easeOut(duration: 0.9).delay(Double(index) * 0.015), value: burst)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, newValue in
            guard newValue else {
                burst = false
                return
            }
            burst = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                burst = true
            }
        }
    }

    private func angle(for index: Int) -> Double {
        Double(index) / 16.0 * Double.pi * 2.0
    }

    private func radius(for index: Int) -> CGFloat {
        CGFloat(54 + (index % 4) * 12)
    }
}

#Preview {
    ConfettiBurstView(isActive: true)
        .frame(width: 180, height: 180)
}
