import SwiftData
import Foundation

enum ManufacturingStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case cancelled
}

@Model
final class ManufacturingEntity {

    var status: ManufacturingStatus = ManufacturingStatus.pending
    var currentStepIndex: Int = 0
    var quantity: Int = 1
    var startedAt: Date = Date.now
    var completedAt: Date?
    var stepCompletionTimes: [Date] = []

    @Relationship
    var recipe: RecipeEntity

    init(
        recipe: RecipeEntity,
        quantity: Int = 1
    ) {
        self.recipe = recipe
        self.quantity = quantity
        self.status = .inProgress
        self.currentStepIndex = 0
        self.startedAt = Date.now
        self.completedAt = nil
        self.stepCompletionTimes = []
    }

    var progress: Double {
        guard recipe.steps.count > 0 else { return 1.0 }
        return Double(currentStepIndex) / Double(recipe.steps.count)
    }

    var currentStep: RecipeStepEntity? {
        let sorted = recipe.sortedSteps
        guard currentStepIndex < sorted.count else { return nil }
        return sorted[currentStepIndex]
    }

    var isCompleted: Bool {
        status == .completed
    }

    var totalSteps: Int {
        recipe.steps.count
    }

    var totalDuration: TimeInterval {
        guard let completedAt else { return 0 }
        return completedAt.timeIntervalSince(startedAt)
    }

    func stepDuration(at index: Int) -> TimeInterval {
        guard index < stepCompletionTimes.count else { return 0 }
        let endTime = stepCompletionTimes[index]
        let startTime = index == 0 ? startedAt : stepCompletionTimes[index - 1]
        return endTime.timeIntervalSince(startTime)
    }

    func stepCompletionTime(at index: Int) -> Date? {
        guard index < stepCompletionTimes.count else { return nil }
        return stepCompletionTimes[index]
    }

    func completeCurrentStep() {
        stepCompletionTimes.append(Date.now)
        currentStepIndex += 1
        if currentStepIndex >= recipe.steps.count {
            status = .completed
            completedAt = Date.now
        }
    }
}
