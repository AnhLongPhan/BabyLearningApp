import SwiftUI

struct MascotView: View {
    let emoji: String
    let message: String?
    @State private var isFloating = false

    init(emoji: String = "🐻", message: String? = nil) {
        self.emoji = emoji
        self.message = message
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 48))
                .offset(y: isFloating ? -4 : 4)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isFloating)

            if let message, !message.isEmpty {
                Text(message)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .onAppear {
            isFloating = true
        }
    }
}

#Preview {
    MascotView(message: "Cùng chơi nhé!")
        .padding()
}
