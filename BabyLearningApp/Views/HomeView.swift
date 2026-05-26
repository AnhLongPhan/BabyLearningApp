import SwiftUI

struct HomeView: View {
    @AppStorage("stickerRewardCount") private var stickerRewardCount = 0
    @AppStorage("childName") private var childName = "Bé"
    @AppStorage("childAvatarEmoji") private var childAvatarEmoji = "😊"
    @AppStorage("childAvatarPath") private var childAvatarPath = ""

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HomeWorldBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        hero
                        gameGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 112)
                }

                bottomBar
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
        }
    }

    private var displayName: String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Bé" : trimmedName
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                Text("Xin chào")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black.opacity(0.78))

                Text("\(displayName)! 👋")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Spacer(minLength: 10)

            NavigationLink {
                StickerCollectionView()
            } label: {
                HStack(spacing: 8) {
                    Image("home_update_reward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)

                    Text("Phần thưởng")
                        .font(.headline.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .foregroundStyle(Color(red: 0.35, green: 0.20, blue: 0.92))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.88, green: 0.72, blue: 1.0), Color(red: 0.72, green: 0.62, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.7), lineWidth: 2)
                }
                .shadow(color: .purple.opacity(0.22), radius: 10, y: 5)
            }
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.88))
                .frame(width: 88, height: 88)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 5)
                }
                .shadow(color: .blue.opacity(0.18), radius: 10, y: 5)

            if childAvatarPath.isEmpty {
                Image("home_update_avatar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 82)
            } else {
                AvatarImageView(imagePath: childAvatarPath, size: 76)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottom) {
            Image("home_update_bear")
                .resizable()
                .scaledToFit()
                .frame(width: 168, height: 168)
                .offset(x: -124, y: -16)

            Image("home_update_avatar")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .offset(x: 98, y: -20)

            VStack(spacing: -2) {
                Text("Học mà chơi")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(Color(red: 0.47, green: 0.25, blue: 0.08))

                Text("Chơi mà vui")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color(red: 1.0, green: 0.38, blue: 0.47))
                    .shadow(color: .white, radius: 0, x: 0, y: 2)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.96, green: 0.73, blue: 0.38), Color(red: 0.80, green: 0.48, blue: 0.22)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.55), lineWidth: 3)
            }
            .shadow(color: .brown.opacity(0.25), radius: 14, y: 8)
            .offset(y: 28)
        }
        .frame(height: 315)
        .overlay(alignment: .topLeading) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("\(stickerRewardCount)")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(.white.opacity(0.78), in: Capsule())
            .offset(x: 120, y: 14)
        }
    }

    private var gameGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            NavigationLink {
                AlphabetLearningView()
            } label: {
                HomeGameTile(title: "Tìm chữ", imageName: "home_update_alphabet", colors: [.yellow, .orange])
            }

            NavigationLink {
                NumberLearningView()
            } label: {
                HomeGameTile(title: "Tìm số", imageName: "home_update_number", colors: [.cyan, .blue])
            }

            NavigationLink {
                CountingGameView()
            } label: {
                HomeGameTile(title: "Đếm đồ vật", imageName: "home_update_counting", colors: [.green, .mint])
            }

            NavigationLink {
                ListenAndPickGameView(mode: .alphabet)
            } label: {
                HomeGameTile(title: "Nghe chọn chữ", imageName: "home_update_listen_letter", colors: [.purple, .indigo])
            }

            NavigationLink {
                ListenAndPickGameView(mode: .number)
            } label: {
                HomeGameTile(title: "Nghe chọn số", imageName: "home_update_listen_number", colors: [.pink, .red])
            }

            NavigationLink {
                PlaySessionView()
            } label: {
                HomeGameTile(title: "Chơi 3 phút", imageName: "home_update_play", colors: [.orange, .yellow])
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            BottomHomeItem(title: "Trang chủ", imageName: "home_update_house", isSelected: true)

            NavigationLink {
                PlaySessionView()
            } label: {
                BottomHomeItem(title: "Trò chơi", imageName: "home_update_gamepad", isSelected: false)
            }

            NavigationLink {
                AlphabetLearningView()
            } label: {
                BottomHomeItem(title: "Học tập", imageName: "home_update_book", isSelected: false)
            }

            NavigationLink {
                SettingsView()
            } label: {
                BottomHomeItem(title: "Của bé", imageName: "home_update_baby", isSelected: false)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.65), lineWidth: 2)
        }
        .shadow(color: .purple.opacity(0.20), radius: 14, y: 6)
    }
}

private struct HomeGameTile: View {
    let title: String
    let imageName: String
    let colors: [Color]
    @State private var isFloating = false

    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 98)
                .scaleEffect(1.14)
                .offset(y: isFloating ? -4 : 2)
                .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: isFloating)

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color(red: 0.12, green: 0.12, blue: 0.34))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.62)
                .frame(height: 34)
                .padding(.horizontal, 6)
                .background(.white.opacity(0.82), in: Capsule())
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 7)
        .frame(maxWidth: .infinity)
        .frame(height: 138)
        .background(
            LinearGradient(colors: colors.map { $0.opacity(0.78) }, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.72), lineWidth: 3)
        }
        .shadow(color: colors.first?.opacity(0.25) ?? .black.opacity(0.12), radius: 8, y: 4)
        .buttonStyle(.plain)
        .onAppear {
            isFloating = true
        }
    }
}

private struct BottomHomeItem: View {
    let title: String
    let imageName: String
    let isSelected: Bool

    private var iconSize: CGFloat {
        imageName == "home_update_house" ? 50 : 44
    }

    var body: some View {
        VStack(spacing: 2) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .scaleEffect(imageName == "home_update_house" ? 1.22 : 1.08)
                .opacity(isSelected ? 1 : 0.72)

            Text(title)
                .font(.system(size: 13, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(isSelected ? Color(red: 0.45, green: 0.30, blue: 0.95) : Color(red: 0.42, green: 0.36, blue: 0.70).opacity(0.75))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? .white.opacity(0.72) : .clear, in: Capsule())
        .contentShape(Rectangle())
    }
}

private struct HomeWorldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.23, green: 0.72, blue: 1.0),
                    Color(red: 0.74, green: 0.92, blue: 1.0),
                    Color(red: 0.52, green: 0.82, blue: 0.36)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(Color(red: 0.50, green: 0.80, blue: 0.30))
                    .frame(height: 310)
                    .offset(y: 72)
            }
            .ignoresSafeArea()

            DecorativeCloud(x: 18, y: 132, scale: 0.95)
            DecorativeCloud(x: 272, y: 176, scale: 0.74)
            DecorativeCloud(x: 26, y: 440, scale: 0.64)

            Image(systemName: "sparkles")
                .font(.title2.bold())
                .foregroundStyle(.white.opacity(0.8))
                .offset(x: -92, y: -300)

            Image(systemName: "sparkles")
                .font(.headline.bold())
                .foregroundStyle(.white.opacity(0.8))
                .offset(x: 146, y: -214)
        }
    }
}

private struct DecorativeCloud: View {
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat

    var body: some View {
        HStack(spacing: -14 * scale) {
            Circle().frame(width: 62 * scale, height: 62 * scale)
            Circle().frame(width: 86 * scale, height: 86 * scale)
            Circle().frame(width: 66 * scale, height: 66 * scale)
        }
        .foregroundStyle(.white.opacity(0.55))
        .offset(x: x - 190, y: y - 420)
        .blur(radius: 0.5)
    }
}

#Preview {
    HomeView()
}
