import SwiftUI

struct BigPrimaryButton: View {
    let title: String
    let systemImage: String?
    let backgroundColor: Color
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        backgroundColor: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage ?? "circle.fill")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, minHeight: 62)
                .foregroundStyle(.white)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    BigPrimaryButton("Nghe", systemImage: "speaker.wave.2.fill") {}
        .padding()
}
