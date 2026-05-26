import SwiftUI

struct FloatingBubbleContainer<Content: View>: View {
    let height: CGFloat
    @ViewBuilder let content: (CGSize) -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                content(geometry.size)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: height)
    }
}

#Preview {
    FloatingBubbleContainer(height: 260) { size in
        Circle()
            .fill(.pink)
            .frame(width: 120, height: 120)
            .position(x: size.width * 0.5, y: size.height * 0.5)
    }
    .padding()
}
