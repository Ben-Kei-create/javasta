import SwiftUI
import Observation

@Observable
final class QuizViewModel {
    var quiz: Quiz
    var selectedChoiceId: String?
    var isAnswered = false
    private var startedAt = Date()

    var selectedChoice: Quiz.Choice? {
        guard let id = selectedChoiceId else { return nil }
        return quiz.choices.first { $0.id == id }
    }

    var isCorrect: Bool { selectedChoice?.correct == true }

    init(quiz: Quiz) {
        self.quiz = quiz
    }

    func select(_ choice: Quiz.Choice) {
        guard !isAnswered else { return }
        selectedChoiceId = choice.id
        let elapsedSeconds = max(1, Int(Date().timeIntervalSince(startedAt).rounded()))
        ProgressStore.shared.recordAnswer(
            quiz: quiz,
            choice: choice,
            elapsedSeconds: elapsedSeconds
        )
        withAnimation(.jbSpring) {
            isAnswered = true
        }
    }

    func reset() {
        withAnimation(.jbFast) {
            selectedChoiceId = nil
            isAnswered = false
            startedAt = Date()
        }
    }
}
