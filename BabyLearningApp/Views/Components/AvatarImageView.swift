import SwiftUI
import UIKit

struct AvatarImageView: View {
    let imagePath: String
    let size: CGFloat

    init(imagePath: String, size: CGFloat = 72) {
        self.imagePath = imagePath
        self.size = size
    }

    var body: some View {
        Group {
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text("🙂")
                    .font(.system(size: size * 0.48))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.orange.opacity(0.22))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(.white, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }

    private var avatarImage: UIImage? {
        guard !imagePath.isEmpty else { return nil }
        return UIImage(contentsOfFile: imagePath)
    }
}

#Preview {
    AvatarImageView(imagePath: "")
        .padding()
}
