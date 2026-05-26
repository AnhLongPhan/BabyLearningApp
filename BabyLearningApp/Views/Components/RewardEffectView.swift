import SwiftUI

struct RewardEffectView: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            ConfettiBurstView(isActive: isActive)

            if isActive {
                Image(systemName: "sparkles")
                    .font(.system(size: 54, weight: .black))
                    .foregroundStyle(.yellow)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    RewardEffectView(isActive: true)
        .frame(width: 180, height: 180)
}
