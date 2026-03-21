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

    var batchNumber: String = ""    // e.g., "250201-001"
    var status: ManufacturingStatus = ManufacturingStatus.pending
    var currentStepIndex: Int = 0 // Keep for backward compatibility/default linear flow
    var completedStepIndices: [Int] = [] // NEW: indices of completed steps
    var quantity: Int = 1
    var startedAt: Date = Date.now
    var completedAt: Date?
    var stepCompletionTimes: [Date] = []
    var stepNotes: [String] = []
    var actualOutput: Double? // NEW: For flexible output tracking

    @Relationship(deleteRule: .cascade)
    var images: [ManufacturingImageEntity] = [] // NEW: Multiple photos of finished work

    @Relationship(deleteRule: .cascade)
    var measurements: [MeasurementLogEntity] = []

    @Relationship
    var recipe: RecipeEntity

    init(
        recipe: RecipeEntity,
        quantity: Int = 1,
        batchNumber: String
    ) {
        self.recipe = recipe
        self.quantity = quantity
        self.batchNumber = batchNumber
        self.status = .inProgress
        self.currentStepIndex = 0
        self.completedStepIndices = []
        self.startedAt = Date.now
        self.completedAt = nil
        self.stepCompletionTimes = []
        self.stepNotes = []
        self.images = []
    }

    /// Add a photo of the work result
    func addImage(_ data: Data) {
        let newImage = ManufacturingImageEntity(imageData: data, manufacturing: self)
        images.append(newImage)
    }


    /// Check if a specific step is completed
    func isStepCompleted(at index: Int) -> Bool {
        completedStepIndices.contains(index)
    }

    /// Check if a step can be completed (all dependencies must be finished)
    func canCompleteStep(at index: Int) -> Bool {
        let sorted = recipe.sortedSteps
        guard index < sorted.count else { return false }
        let step = sorted[index]
        
        // If there are dependencies, all must be in completedStepIndices
        for dependency in step.dependencies {
            if let depIndex = sorted.firstIndex(where: { $0.persistentModelID == dependency.persistentModelID }) {
                if !completedStepIndices.contains(depIndex) {
                    return false
                }
            }
        }
        return true
    }

    /// Complete a specific step (can be non-linear)
    func completeStep(at index: Int, note: String = "") {
        guard !isStepCompleted(at: index) else { return }
        
        completedStepIndices.append(index)
        // For simplicity in reporting for now, we still use stepCompletionTimes/Notes
        // but might need mapping if they are out of order
        stepCompletionTimes.append(Date.now)
        stepNotes.append(note)
        
        // Check if all steps are done
        if completedStepIndices.count >= recipe.steps.count {
            status = .completed
            completedAt = Date.now
        }
        
        // Move currentStepIndex for linear views
        if index == currentStepIndex {
            while isStepCompleted(at: currentStepIndex) && currentStepIndex < recipe.steps.count {
                currentStepIndex += 1
            }
        }
    }

    /// Generate a batch number based on date and sequence
    /// Format: YYMMDD-XXX (e.g., 250201-001)
    static func generateBatchNumber(existingBatches: [ManufacturingEntity]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        let datePrefix = formatter.string(from: Date.now)

        // Find today's batches and get the next sequence
        let todayBatches = existingBatches.filter { $0.batchNumber.hasPrefix(datePrefix) }
        let maxSequence = todayBatches.compactMap { batch -> Int? in
            let parts = batch.batchNumber.split(separator: "-")
            guard parts.count == 2, let seq = Int(parts[1]) else { return nil }
            return seq
        }.max() ?? 0

        let nextSequence = maxSequence + 1
        return String(format: "%@-%03d", datePrefix, nextSequence)
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

    /// Total cost for this manufacturing run (based on quantity of batches)
    var totalCost: Double {
        recipe.cost(forBatches: quantity)
    }

    /// Total units that will be produced
    var totalUnits: Int {
        recipe.units(forBatches: quantity)
    }

    /// Cost per unit for this run
    var costPerUnit: Double {
        recipe.costPerUnit
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

    func completeCurrentStep(note: String = "") {
        stepCompletionTimes.append(Date.now)
        stepNotes.append(note)
        currentStepIndex += 1
        if currentStepIndex >= recipe.steps.count {
            status = .completed
            completedAt = Date.now
        }
    }

    func stepNote(at index: Int) -> String? {
        guard index < stepNotes.count else { return nil }
        let note = stepNotes[index]
        return note.isEmpty ? nil : note
    }

    /// Log a quality control measurement for a step
    func logMeasurement(type: MeasurementType, value: Double, stepIndex: Int) {
        // Remove existing if any
        measurements.removeAll { $0.stepIndex == stepIndex && $0.type == type }
        
        let log = MeasurementLogEntity(type: type, value: value, stepIndex: stepIndex, manufacturing: self)
        measurements.append(log)
    }

    /// Get measurements for a specific step
    func getMeasurements(at stepIndex: Int) -> [MeasurementLogEntity] {
        measurements.filter { $0.stepIndex == stepIndex }
    }

    /// Check if all required measurements for a step are logged
    func hasRequiredMeasurements(at index: Int) -> Bool {
        let sorted = recipe.sortedSteps
        guard index < sorted.count else { return true }
        let step = sorted[index]
        let logged = getMeasurements(at: index).map { $0.type }
        
        return step.requiredMeasurements.allSatisfy { logged.contains($0) }
    }
}
