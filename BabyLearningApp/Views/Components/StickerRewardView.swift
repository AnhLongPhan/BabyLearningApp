import SwiftUI

struct StickerRewardView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("\(count)")
                .font(.headline.bold())
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.86), in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .accessibilityLabel("Sao thưởng: \(count)")
    }
}

#Preview {
    StickerRewardView(count: 12)
        .padding()
}
