import SwiftUI

struct AudioReplayButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Nghe lại", systemImage: "speaker.wave.2.fill")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(minHeight: 54)
                .background(.blue, in: Capsule())
                .shadow(color: .blue.opacity(0.22), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Nghe lại câu hỏi")
    }
}

#Preview {
    AudioReplayButton {}
        .padding()
}
