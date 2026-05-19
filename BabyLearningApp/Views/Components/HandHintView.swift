import SwiftUI
import UIKit

struct HandHintView: View {
    let answer: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("Gợi ý")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Group {
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                } else {
                    fallbackView
                }
            }
            .frame(width: 60, height: 40)
        }
        .padding(7)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
        .accessibilityLabel("Gợi ý bằng tay: \(answer)")
    }

    private var imageName: String {
        "hand_\(min(max(answer, 1), 10))"
    }

    private var fallbackView: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.orange)

            if answer > 5 {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.orange.opacity(0.82))
            }

            Text("\(answer)")
                .font(.headline.bold())
                .foregroundStyle(.pink)
        }
    }
}

#Preview {
    HandHintView(answer: 8)
        .padding()
        .background(Color(.systemGroupedBackground))
}
