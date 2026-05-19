import Foundation

@MainActor
protocol GameRoundViewModel {
    associatedtype FeedbackState

    var feedbackState: FeedbackState { get }
    var feedbackText: String { get }

    func generateNewRound()
}
