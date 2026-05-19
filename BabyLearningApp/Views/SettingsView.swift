import PhotosUI
import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("maxNumberValue") private var maxNumberValue = 10
    @AppStorage("enabledAlphabetCharacters") private var enabledAlphabetCharacters = "ABC"
    @AppStorage("maxMathSum") private var maxMathSum = 5
    @AppStorage("speechLanguageCode") private var speechLanguageCode = "vi-VN"
    @AppStorage("childName") private var childName = ""
    @AppStorage("childAvatarPath") private var childAvatarPath = ""
    @State private var selectedAvatarItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section("Hồ sơ của bé") {
                HStack(spacing: 16) {
                    AvatarImageView(imagePath: childAvatarPath, size: 76)

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Tên bé", text: $childName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()

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
        }
        .navigationTitle("Cài đặt")
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    NavigationStack {
        SettingsView()
    }
}
