import SwiftUI

struct HomeBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.88))
                                .overlay {
                                    Circle()
                                        .stroke(Color.green.opacity(0.28), lineWidth: 2)
                                }

                            Image("home_update_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                        }
                        .frame(width: 62, height: 62)
                        .compositingGroup()
                        .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Quay lại")
                }
            }
    }
}

extension View {
    @ViewBuilder
    func homeBackButton(_ isVisible: Bool = true) -> some View {
        if isVisible {
            modifier(HomeBackButtonModifier())
        } else {
            self
        }
    }
}
