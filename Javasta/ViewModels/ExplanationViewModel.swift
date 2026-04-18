import SwiftUI
import Observation

@Observable
final class ExplanationViewModel {
    var explanation: Explanation
    private(set) var currentStepIndex = 0
    var predictSelectedIndex: Int?
    var predictAnswered = false
    var showPredictHint = false

    var currentStep: Explanation.Step { explanation.steps[currentStepIndex] }

    var previousStep: Explanation.Step? {
        currentStepIndex > 0 ? explanation.steps[currentStepIndex - 1] : nil
    }

    var canGoBack: Bool    { currentStepIndex > 0 }
    var canGoForward: Bool { currentStepIndex < explanation.steps.count - 1 }
    var isComplete: Bool   { currentStepIndex == explanation.steps.count - 1 }
    var progress: Double   { Double(currentStepIndex + 1) / Double(explanation.steps.count) }

    var isPredictBlocking: Bool {
        currentStep.predict != nil && !predictAnswered
    }

    init(explanation: Explanation) {
        self.explanation = explanation
    }

    func goForward() {
        guard canGoForward, !isPredictBlocking else { return }
        withAnimation(.jbSpring) {
            currentStepIndex += 1
            resetPredict()
        }
    }

    func goBack() {
        guard canGoBack else { return }
        withAnimation(.jbSpring) {
            currentStepIndex -= 1
            resetPredict()
        }
    }

    func selectPredict(index: Int) {
        guard !predictAnswered else { return }
        predictSelectedIndex = index
        withAnimation(.jbSpring) { predictAnswered = true }
    }

    private func resetPredict() {
        predictSelectedIndex = nil
        predictAnswered = false
        showPredictHint = false
    }
}
