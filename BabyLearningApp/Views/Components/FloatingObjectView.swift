import SwiftUI

struct FloatingObjectView: View {
    let emoji: String
    let rotation: Double
    let xOffset: CGFloat
    let yOffset: CGFloat
    let isFloating: Bool
    let delay: Double
    @State private var floatsUp = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 36))
            .frame(width: 46, height: 46)
            .background(.white.opacity(0.66), in: Circle())
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset + (floatsUp ? -5 : 5))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
            .animation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true).delay(delay), value: floatsUp)
            .onAppear {
                floatsUp = isFloating
            }
            .onChange(of: isFloating) { _, newValue in
                floatsUp = newValue
            }
    }
}

#Preview {
    FloatingObjectView(emoji: "🍎", rotation: -8, xOffset: 0, yOffset: 0, isFloating: true, delay: 0)
        .padding()
}
