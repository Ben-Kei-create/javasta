import SwiftUI
import Observation

@Observable
final class QuizViewModel {
    var quiz: Quiz
    var selectedChoiceId: String?
    var isAnswered = false

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
        ProgressStore.shared.recordAnswer(quizId: quiz.id, correct: choice.correct)
        withAnimation(.jbSpring) {
            isAnswered = true
        }
    }

    func reset() {
        withAnimation(.jbFast) {
            selectedChoiceId = nil
            isAnswered = false
        }
    }
}
