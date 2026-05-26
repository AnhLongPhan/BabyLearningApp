import Foundation

enum PersonalizationService {
    static func displayName(_ childName: String) -> String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Bé" : trimmedName
    }

    static func welcomeText(childName: String) -> String {
        "Xin chào \(displayName(childName)) 👋"
    }

    static func mascotReadyText(childName: String) -> String {
        "\(displayName(childName)) sẵn sàng chưa?"
    }

    static func mascotPraiseText(childName: String) -> String {
        [
            "\(displayName(childName)) làm giỏi quá!",
            "Mình cùng chơi tiếp nhé \(displayName(childName))!",
            "\(displayName(childName)) thật chăm học!"
        ].randomElement() ?? "\(displayName(childName)) làm giỏi quá!"
    }

    static func letterPrompt(_ letter: String, childName: String) -> String {
        "\(displayName(childName)) ơi, hãy tìm chữ \(letter) nhé"
    }

    static func letterExplorePrompt(childName: String) -> String {
        "\(displayName(childName)) chạm vào bong bóng chữ để nghe âm nhé"
    }

    static func letterChallengePrompt(_ letter: String, childName: String) -> String {
        "\(displayName(childName)) ơi, hãy tìm chữ \(letter) đang phát âm nhé"
    }

    static func letterSound(_ letter: String) -> String {
        "\(letter.lowercased())..."
    }

    static func numberPrompt(_ number: Int, childName: String) -> String {
        "\(displayName(childName)) ơi, có biết đâu là số \(number)?"
    }

    static func mathPrompt(leftNumber: Int, rightNumber: Int, objectName: String, childName: String) -> String {
        "\(displayName(childName)) ơi, \(spokenNumber(leftNumber)) cộng \(spokenNumber(rightNumber)) bằng mấy? Hãy đếm \(objectName) nhé"
    }

    static func countingPrompt(objectName: String, childName: String) -> String {
        "\(displayName(childName)) ơi, Hãy đếm có bao nhiêu \(objectName) nào?"
    }

    static func praise(childName: String) -> String {
        [
            "Giỏi quá \(displayName(childName))!",
            "\(displayName(childName)) làm tốt lắm!",
            "Chính xác rồi \(displayName(childName))!",
            "\(displayName(childName)) đúng là em bé vừa ngoan vừa giỏi nha!"
        ].randomElement() ?? "Giỏi quá \(displayName(childName))!"
    }

    static func retryText(childName: String, hintLevel: Int) -> String {
        switch hintLevel {
        case 1:
            return "\(displayName(childName)) thử lại nhé"
        case 2:
            return "\(displayName(childName)) nhìn kỹ lại nào"
        default:
            return "Không sao đâu \(displayName(childName)), mình cùng thử lại nhé"
        }
    }

    static func retrySpeech(childName: String, hintLevel: Int) -> String {
        switch hintLevel {
        case 1:
            return "\(displayName(childName)) thử lại nhé"
        case 2:
            return "\(displayName(childName)) nhìn kỹ lại nhé"
        default:
            return "Đây là đáp án đúng nè \(displayName(childName)), hãy chạm vào nhé"
        }
    }

    static func guidedHint(childName: String) -> String {
        "\(displayName(childName)) chạm vào đáp án đang phát sáng nhé"
    }

    private static func spokenNumber(_ number: Int) -> String {
        switch number {
        case 1: return "một"
        case 2: return "hai"
        case 3: return "ba"
        case 4: return "bốn"
        case 5: return "năm"
        case 6: return "sáu"
        case 7: return "bảy"
        case 8: return "tám"
        case 9: return "chín"
        case 10: return "mười"
        default: return "\(number)"
        }
    }
}
