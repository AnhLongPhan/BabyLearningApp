import SwiftUI
import UIKit

struct ReusableImageView: View {
    let imageName: String
    let placeholderSymbol: String

    init(imageName: String, placeholderSymbol: String = "photo") {
        self.imageName = imageName
        self.placeholderSymbol = placeholderSymbol
    }

    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .accessibilityHidden(true)
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.62))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white, style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                }

            Image(systemName: placeholderSymbol)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ReusableImageView(imageName: "alphabet_a")
        .padding()
        .background(.mint.opacity(0.2))
}
