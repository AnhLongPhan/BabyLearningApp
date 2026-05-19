import Foundation

enum LearningLanguage: String, CaseIterable, Identifiable {
    case vietnamese = "vi-VN"
    case english = "en-US"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vietnamese:
            return "Tiếng Việt"
        case .english:
            return "English"
        }
    }

    var speechCode: String {
        rawValue
    }

    static func from(_ code: String) -> LearningLanguage {
        LearningLanguage(rawValue: code) ?? .vietnamese
    }

    var alphabetPraiseSentences: [String] {
        switch self {
        case .vietnamese:
            return ["Giỏi quá!", "Bé chọn đúng rồi!", "Tuyệt vời!"]
        case .english:
            return ["Great job!", "You picked the right one!", "Wonderful!"]
        }
    }

    var numberPraiseSentences: [String] {
        switch self {
        case .vietnamese:
            return ["Giỏi quá!", "Bé làm tốt lắm!", "Chính xác rồi!"]
        case .english:
            return ["Great job!", "Well done!", "That's correct!"]
        }
    }

    var mathPraiseSentences: [String] {
        switch self {
        case .vietnamese:
            return ["Giỏi quá!", "Chính xác rồi!", "Bé làm tốt lắm!"]
        case .english:
            return ["Great job!", "That's correct!", "Well done!"]
        }
    }

    func personalizedPraise(_ praise: String, childName: String) -> String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return praise }

        switch self {
        case .vietnamese:
            return [
                "\(trimmedName) giỏi quá!",
                "\(trimmedName) thật thông minh quá!",
                "\(trimmedName) làm đúng rồi!",
                "\(trimmedName) đúng là em bé vừa ngoan vừa giỏi nha!"
            ].randomElement() ?? "\(trimmedName) giỏi quá!"
        case .english:
            return [
                "\(trimmedName), great job!",
                "\(trimmedName), you are so smart!",
                "\(trimmedName), that's correct!",
                "\(trimmedName), you did wonderfully!"
            ].randomElement() ?? "\(trimmedName), great job!"
        }
    }

    var correctFeedback: String {
        switch self {
        case .vietnamese:
            return "Giỏi quá!"
        case .english:
            return "Great job!"
        }
    }

    func retryFeedback(childName: String = "") -> String {
        let displayName = childDisplayName(childName)

        switch self {
        case .vietnamese:
            return "\(displayName) thử lại nhé!"
        case .english:
            return "\(displayName), try again!"
        }
    }

    func wrongSpeechText(childName: String = "") -> String {
        let displayName = childDisplayName(childName)

        switch self {
        case .vietnamese:
            return "Chưa đúng rồi, \(displayName) hãy chọn lại nhé"
        case .english:
            return "Not quite, \(displayName). Please try again."
        }
    }

    func findLetterPrompt(_ letter: String, childName: String = "") -> String {
        switch self {
        case .vietnamese:
            return "\(childDisplayName(childName)) hãy tìm chữ \(letter)"
        case .english:
            return "\(childDisplayName(childName)), find the letter \(letter)"
        }
    }

    func letterConfirmation(_ letter: String) -> String {
        switch self {
        case .vietnamese:
            return "Đây là chữ \(letter)"
        case .english:
            return "This is the letter \(letter)"
        }
    }

    func findNumberPrompt(_ number: Int, childName: String = "") -> String {
        switch self {
        case .vietnamese:
            return "\(childDisplayName(childName)) hãy tìm số \(number)"
        case .english:
            return "\(childDisplayName(childName)), find the number \(number)"
        }
    }

    func mathQuestion(leftNumber: Int, rightNumber: Int, objectName: String, childName: String = "") -> String {
        switch self {
        case .vietnamese:
            return "\(childDisplayName(childName)) ơi, \(spokenNumber(leftNumber)) cộng \(spokenNumber(rightNumber)) bằng mấy? Hãy đếm \(objectName) nhé"
        case .english:
            return "\(childDisplayName(childName)), what is \(leftNumber) plus \(rightNumber)? Let's count the \(objectName)."
        }
    }

    func countingQuestion(objectName: String, childName: String = "") -> String {
        switch self {
        case .vietnamese:
            return "\(childDisplayName(childName)) ơi, có bao nhiêu \(objectName)?"
        case .english:
            return "\(childDisplayName(childName)), how many \(objectName) are there?"
        }
    }

    private func childDisplayName(_ childName: String) -> String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            switch self {
            case .vietnamese:
                return "Bé"
            case .english:
                return "You"
            }
        }

        return trimmedName
    }

    private func spokenNumber(_ number: Int) -> String {
        switch self {
        case .vietnamese:
            switch number {
            case 1:
                return "Một"
            case 2:
                return "Hai"
            case 3:
                return "Ba"
            case 4:
                return "Bốn"
            case 5:
                return "Năm"
            case 6:
                return "Sáu"
            case 7:
                return "Bảy"
            case 8:
                return "Tám"
            case 9:
                return "Chín"
            case 10:
                return "Mười"
            default:
                return "\(number)"
            }
        case .english:
            return "\(number)"
        }
    }
}
