import SwiftUI

struct LearningCardView<Content: View>: View {
    let backgroundColor: Color
    @ViewBuilder let content: Content

    init(backgroundColor: Color = Color(.secondarySystemBackground), @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 18) {
            content
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 2)
        }
    }
}

#Preview {
    LearningCardView(backgroundColor: .yellow.opacity(0.3)) {
        Text("A")
            .font(.system(size: 96, weight: .bold))
    }
    .padding()
}
