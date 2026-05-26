import SwiftUI

struct MascotSpeechBubble: View {
    let emoji: String
    let message: String
    @State private var isFloating = false

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 46))
                .offset(y: isFloating ? -4 : 4)
                .animation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true), value: isFloating)

            Text(message)
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .onAppear {
            isFloating = true
        }
    }
}

#Preview {
    MascotSpeechBubble(emoji: "🐰", message: "Cùng chơi với chữ nhé!")
        .padding()
}
