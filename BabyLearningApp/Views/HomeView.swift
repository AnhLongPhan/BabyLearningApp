import SwiftUI

struct HomeView: View {
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = ""
    @AppStorage("childAvatarPath") private var childAvatarPath = ""

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                FloatingBackgroundView(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 1.0),
                        Color(red: 0.90, green: 0.99, blue: 1.0),
                        Color(red: 1.0, green: 0.96, blue: 0.88)
                    ],
                    symbols: ["sparkles", "star.fill", "heart.fill", "circle.fill", "sun.max.fill"]
                )

                ScrollView {
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            HStack(spacing: 10) {
                                AvatarImageView(imagePath: childAvatarPath, size: 54)
                                MascotView(emoji: "🦊", message: homeMessage)
                            }
                            Spacer()
                            StickerRewardView(count: stickerRewardCount)
                        }

                        Text("Bé học vui")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: columns, spacing: 14) {
                            NavigationLink {
                                AlphabetLearningView()
                            } label: {
                                GameTile(title: "Tìm chữ", emoji: "🔤", color: .orange)
                            }

                            NavigationLink {
                                NumberLearningView()
                            } label: {
                                GameTile(title: "Tìm số", emoji: "🔢", color: .teal)
                            }

                            NavigationLink {
                                CountingGameView()
                            } label: {
                                GameTile(title: "Đếm đồ vật", emoji: "🍎", color: .purple)
                            }

                            NavigationLink {
                                MathGameView()
                            } label: {
                                GameTile(title: "Cộng vui", emoji: "➕", color: .pink)
                            }
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2.bold())
                                Text("Cài đặt")
                                    .font(.title3.bold())
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline.bold())
                            }
                            .foregroundStyle(.primary)
                            .padding(18)
                            .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
                        }
                    }
                    .padding(22)
                }
            }
            .navigationTitle("Trang chủ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var homeMessage: String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Chọn trò chơi nào!" : "\(trimmedName) chơi nào!"
    }
}

private struct GameTile: View {
    let title: String
    let emoji: String
    let color: Color
    @State private var isFloating = false

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 52))
                .offset(y: isFloating ? -4 : 4)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isFloating)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding(12)
        .background(color.opacity(0.22), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.82), lineWidth: 3)
        }
        .shadow(color: color.opacity(0.18), radius: 12, y: 7)
        .onAppear {
            isFloating = true
        }
    }
}

#Preview {
    HomeView()
}
