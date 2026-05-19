import Foundation

enum SampleLearningData {
    static let alphabetItems: [AlphabetItem] = [
        AlphabetItem(letter: "A", word: "An", imageName: "alphabet_a", speechText: "Chữ A. A trong từ An."),
        AlphabetItem(letter: "B", word: "Bé", imageName: "alphabet_b", speechText: "Chữ B. B trong từ Bé."),
        AlphabetItem(letter: "C", word: "Cá", imageName: "alphabet_c", speechText: "Chữ C. C trong từ Cá.")
    ]

    static let numberItems: [NumberItem] = [
        NumberItem(number: 1, displayText: "Một", imageName: "number_1", objectCount: 1, speechText: "Số một."),
        NumberItem(number: 2, displayText: "Hai", imageName: "number_2", objectCount: 2, speechText: "Số hai."),
        NumberItem(number: 3, displayText: "Ba", imageName: "number_3", objectCount: 3, speechText: "Số ba."),
        NumberItem(number: 4, displayText: "Bốn", imageName: "number_4", objectCount: 4, speechText: "Số bốn."),
        NumberItem(number: 5, displayText: "Năm", imageName: "number_5", objectCount: 5, speechText: "Số năm.")
    ]

    static let mathQuestions: [MathQuestion] = [
        MathQuestion(leftNumber: 1, rightNumber: 1, options: [1, 2, 3], speechText: "Một cộng một bằng mấy?"),
        MathQuestion(leftNumber: 2, rightNumber: 1, options: [2, 3, 4], speechText: "Hai cộng một bằng mấy?"),
        MathQuestion(leftNumber: 2, rightNumber: 2, options: [3, 4, 5], speechText: "Hai cộng hai bằng mấy?"),
        MathQuestion(leftNumber: 3, rightNumber: 2, options: [4, 5, 6], speechText: "Ba cộng hai bằng mấy?")
    ]
}
