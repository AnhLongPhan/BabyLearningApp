import SwiftUI

struct AudioReplayButton: View {
    var isCompact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isCompact {
                soundIcon(size: 60, imageSize: 60)
            } else {
                HStack(spacing: 8) {
                    soundIcon(size: 60, imageSize: 60)

                    Text("Nghe lại")
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.03))
                        .lineLimit(1)
                }
                .padding(.leading, 7)
                .padding(.trailing, 18)
                .frame(minHeight: 60)
                .background(.white.opacity(0.88), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.orange.opacity(0.42), lineWidth: 2)
                }
                .shadow(color: .orange.opacity(0.20), radius: 8, y: 4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Nghe lại câu hỏi")
    }

    private func soundIcon(size: CGFloat, imageSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.86))
                .overlay {
                    Circle()
                        .stroke(Color.orange.opacity(0.32), lineWidth: 2)
                }

            Image("home_update_sound")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .shadow(color: .orange.opacity(0.22), radius: 8, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioReplayButton(isCompact: true) {}
        AudioReplayButton {}
    }
    .padding()
}
