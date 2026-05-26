import PhotosUI
import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("enabledAlphabetCharacters") private var enabledAlphabetCharacters = "ABC"
    @AppStorage("maxMathSum") private var maxMathSum = 5
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("fptTTSVoiceId") private var fptTTSVoiceId = "linhsan"
    @AppStorage("fptAPIKey") private var fptAPIKey = TTSConfig.bundledFPTAPIKey
    @AppStorage("childName") private var childName = "Bé"
    @AppStorage("childAvatarEmoji") private var childAvatarEmoji = "😊"
    @AppStorage("childAge") private var childAge = 3
    @AppStorage("childAvatarPath") private var childAvatarPath = ""
    @AppStorage("enabledMathObjectThemes") private var enabledMathObjectThemes = MathObjectTheme.defaultStorageValue
    @State private var selectedAvatarItem: PhotosPickerItem?
    @State private var draftThemeIDs: Set<String> = []
    @State private var showUpdateConfirmation = false

    private let illustrationColumns = [
        GridItem(.adaptive(minimum: 86), spacing: 12)
    ]

    var body: some View {
        Form {
            Section("Hồ sơ của bé") {
                HStack(spacing: 16) {
                    AvatarImageView(imagePath: childAvatarPath, size: 76)

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Tên bé", text: $childName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()

                        Picker("Avatar", selection: $childAvatarEmoji) {
                            ForEach(["😊", "🐻", "🐰", "🦊", "🐼", "🌟"], id: \.self) { emoji in
                                Text(emoji).tag(emoji)
                            }
                        }
                        .pickerStyle(.segmented)

                        Stepper("Tuổi: \(childAge)", value: $childAge, in: 3...6)

                        PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                            Label("Chọn avatar", systemImage: "photo.on.rectangle")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }

            Section("Ngôn ngữ") {
                Picker("Giọng đọc", selection: $speechLanguageCode) {
                    ForEach(LearningLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language.speechCode)
                    }
                }

                Picker("Giọng FPT", selection: $fptTTSVoiceId) {
                    Text("Linh San").tag("linhsan")
                    Text("Ban Mai").tag("banmai")
                    Text("Thu Minh").tag("thuminh")
                    Text("Lan Nhi").tag("lannhi")
                }

                SecureField("FPT API Key", text: $fptAPIKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Text("App có sẵn key mặc định. Nếu key hết token, nhập key mới tại đây để thay thế và app sẽ dùng key mới cho các lần tạo giọng tiếp theo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Học số") {
                Stepper("Số lớn nhất: \(maxNumberValue)", value: $maxNumberValue, in: 3...10)
                Text("Game sẽ chọn số từ 1 đến \(maxNumberValue).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Chữ cái") {
                TextField("Ví dụ: ABC", text: $enabledAlphabetCharacters)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onChange(of: enabledAlphabetCharacters) { _, newValue in
                        enabledAlphabetCharacters = sanitizedLetters(from: newValue)
                    }

                Text("Chỉ hiển thị các chữ có trong dữ liệu mẫu hiện tại.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Phép cộng") {
                Stepper("Tổng lớn nhất: \(maxMathSum)", value: $maxMathSum, in: 2...10)
                Text("Câu hỏi cộng sẽ có kết quả không vượt quá \(maxMathSum).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Minh hoạ") {
                LazyVGrid(columns: illustrationColumns, spacing: 12) {
                    ForEach(MathObjectTheme.allCases) { theme in
                        IllustrationThemeButton(
                            theme: theme,
                            isSelected: draftThemeIDs.contains(theme.rawValue)
                        ) {
                            toggleTheme(theme)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))

                Button {
                    applyThemeSettings()
                } label: {
                    Label("Cập nhật", systemImage: "checkmark.seal.fill")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(draftThemeIDs.isEmpty)

                Text("Các game đếm đồ vật và cộng vui sẽ chỉ dùng những minh hoạ đã chọn.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Cài đặt")
        .navigationBarTitleDisplayMode(.inline)
        .homeBackButton()
        .alert("Đã cập nhật", isPresented: $showUpdateConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Minh hoạ mới sẽ được dùng trong các câu hỏi tiếp theo.")
        }
        .onAppear {
            draftThemeIDs = Set(MathObjectTheme.themes(from: enabledMathObjectThemes).map(\.rawValue))
        }
        .onChange(of: selectedAvatarItem) { _, newItem in
            guard let newItem else { return }
            Task {
                await saveAvatar(from: newItem)
            }
        }
    }

    private func sanitizedLetters(from value: String) -> String {
        let allowedLetters = value
            .uppercased()
            .filter { $0.isLetter }

        let uniqueLetters = allowedLetters.reduce(into: "") { result, letter in
            if !result.contains(letter) {
                result.append(letter)
            }
        }

        return String(uniqueLetters.prefix(10))
    }

    private func toggleTheme(_ theme: MathObjectTheme) {
        if draftThemeIDs.contains(theme.rawValue) {
            if draftThemeIDs.count > 1 {
                draftThemeIDs.remove(theme.rawValue)
            }
        } else {
            draftThemeIDs.insert(theme.rawValue)
        }
    }

    private func applyThemeSettings() {
        let orderedIDs = MathObjectTheme.allCases
            .map(\.rawValue)
            .filter { draftThemeIDs.contains($0) }

        enabledMathObjectThemes = orderedIDs.joined(separator: ",")
        showUpdateConfirmation = true
    }

    @MainActor
    private func saveAvatar(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let jpegData = image.jpegData(compressionQuality: 0.82) else {
                return
            }

            let avatarURL = try avatarFileURL()
            try jpegData.write(to: avatarURL, options: [.atomic])
            childAvatarPath = avatarURL.path
        } catch {
            // Keep the previous avatar if loading or saving fails.
        }
    }

    private func avatarFileURL() throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return documentsURL.appendingPathComponent("child_avatar.jpg")
    }
}

private struct IllustrationThemeButton: View {
    let theme: MathObjectTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(theme.emoji)
                    .font(.system(size: 42))
                    .frame(width: 62, height: 62)
                    .background(isSelected ? Color.white.opacity(0.95) : Color(.systemGray5), in: Circle())
                    .grayscale(isSelected ? 0 : 1)
                    .opacity(isSelected ? 1 : 0.42)

                Text(theme.name)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .padding(8)
            .background(isSelected ? Color.green.opacity(0.20) : Color(.systemGray6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? .green.opacity(0.75) : .clear, lineWidth: 3)
            }
            .shadow(color: isSelected ? .green.opacity(0.16) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.0 : 0.96)
            .animation(.spring(response: 0.25, dampingFraction: 0.78), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) \(isSelected ? "đã chọn" : "chưa chọn")")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
