import SwiftUI

struct PlaySessionView: View {
    private enum SessionGame: String, CaseIterable, Identifiable {
        case alphabet
        case number
        case math

        var id: String { rawValue }

        var title: String {
            switch self {
            case .alphabet:
                return "Tìm chữ"
            case .number:
                return "Tìm số"
            case .math:
                return "Cộng vui"
            }
        }
    }

    @State private var activeGame: SessionGame = .alphabet
    @State private var remainingSeconds = 180
    @State private var sessionTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .top) {
            activeGameView
                .id(activeGame)

            sessionHeader
                .padding(.horizontal, 14)
                .padding(.top, 8)
        }
        .navigationTitle("Chơi 3 phút")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton()
        .onAppear {
            startSession()
        }
        .onDisappear {
            sessionTask?.cancel()
        }
    }

    @ViewBuilder
    private var activeGameView: some View {
        switch activeGame {
        case .alphabet:
            AlphabetLearningView(showsBackButton: false)
        case .number:
            NumberLearningView(showsBackButton: false)
        case .math:
            MathGameView(showsBackButton: false)
        }
    }

    private var sessionHeader: some View {
        HStack(spacing: 10) {
            Label(timeText, systemImage: "timer")
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.9), in: Capsule())

            Spacer()

            Button {
                rotateGame()
            } label: {
                Image(systemName: "shuffle")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.pink.gradient, in: Circle())
                    .shadow(color: .pink.opacity(0.24), radius: 8, y: 5)
            }
            .accessibilityLabel("Đổi trò chơi")
        }
    }

    private var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startSession() {
        sessionTask?.cancel()
        remainingSeconds = 180
        activeGame = SessionGame.allCases.randomElement() ?? .alphabet

        sessionTask = Task {
            while remainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1

                if remainingSeconds > 0 && remainingSeconds % 45 == 0 {
                    rotateGame()
                }
            }
        }
    }

    private func rotateGame() {
        let nextGames = SessionGame.allCases.filter { $0 != activeGame }
        activeGame = nextGames.randomElement() ?? .alphabet
    }
}

#Preview {
    NavigationStack {
        PlaySessionView()
    }
}
