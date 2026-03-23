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
    var stepLogs: [ManufacturingStepLogEntity] = [] // NEW: Per-step notes and times

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
        self.stepLogs = []
    }

    /// Get log for a specific step, create if not exists
    func getLog(at index: Int) -> ManufacturingStepLogEntity? {
        if let log = stepLogs.first(where: { $0.stepIndex == index }) {
            return log
        }
        return nil
    }

    /// Ensure log exists for a specific step
    func ensureLogExists(at index: Int) -> ManufacturingStepLogEntity {
        if let log = getLog(at: index) {
            return log
        }
        let newLog = ManufacturingStepLogEntity(stepIndex: index, manufacturing: self)
        stepLogs.append(newLog)
        return newLog
    }

    /// Set note for a specific step (without completing it)
    func setStepNote(at index: Int, note: String) {
        let log = ensureLogExists(at: index)
        log.note = note
    }

    /// Get note for a specific step
    func getStepNote(at index: Int) -> String {
        getLog(at: index)?.note ?? ""
    }

    /// Check if a step has started
    func isStepStarted(at index: Int) -> Bool {
        getLog(at: index)?.startedAt != nil
    }

    /// Start a step timer
    func startStep(at index: Int) {
        let log = ensureLogExists(at: index)
        if log.startedAt == nil {
            log.startedAt = Date.now
        }
    }

    /// Record current time as step completion time (without marking step as fully complete)
    func recordStepTime(at index: Int) {
        let log = ensureLogExists(at: index)
        log.completedAt = Date.now
    }

    /// Get start time for a specific step
    func getStepStartTime(at index: Int) -> Date? {
        getLog(at: index)?.startedAt
    }

    /// Add a photo for a specific step or final work result
    func addImage(_ data: Data, stepIndex: Int? = nil) {
        let newImage = ManufacturingImageEntity(imageData: data, stepIndex: stepIndex, manufacturing: self)
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
        
        let now = Date.now
        completedStepIndices.append(index)
        
        // Update new log system
        let log = ensureLogExists(at: index)
        
        // Use already recorded time or current time
        let completionTime = log.completedAt ?? now
        log.completedAt = completionTime
        
        if log.startedAt == nil {
            // Default start time to startedAt of manufacturing or previous step if not manually started
            log.startedAt = stepCompletionTimes.last ?? startedAt
        }
        
        if !note.isEmpty {
            log.note = note
        }
        
        // Maintain old arrays for backward compatibility and simpler reporting
        stepCompletionTimes.append(completionTime)
        stepNotes.append(note)
        
        // Check if all steps are done
        if completedStepIndices.count >= recipe.steps.count {
            status = .completed
            completedAt = completionTime
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
        return Double(completedStepIndices.count) / Double(recipe.steps.count)
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
        if let completedAt {
            return completedAt.timeIntervalSince(startedAt)
        }
        
        // If not completed, use the latest step log's completedAt as the end point
        let latestLogTime = stepLogs.compactMap { $0.completedAt }.max()
        if let latestLogTime {
            return latestLogTime.timeIntervalSince(startedAt)
        }
        
        // If no logs, but it's in progress, show elapsed time since start
        if status == .inProgress {
            return Date.now.timeIntervalSince(startedAt)
        }
        
        return 0
    }

    func stepDuration(at index: Int) -> TimeInterval {
        guard let log = getLog(at: index), let end = log.completedAt else { return 0 }
        
        if let start = log.startedAt {
            return end.timeIntervalSince(start)
        }
        
        // Fallback: Find previous completed step in time
        let previousLogs = stepLogs.filter { $0.completedAt != nil && $0.completedAt! < end }
        let startTime = previousLogs.max(by: { $0.completedAt! < $1.completedAt! })?.completedAt ?? startedAt
        
        return end.timeIntervalSince(startTime)
    }

    func stepCompletionTime(at index: Int) -> Date? {
        getLog(at: index)?.completedAt
    }

    func completeCurrentStep(note: String = "") {
        completeStep(at: currentStepIndex, note: note)
    }

    func stepNote(at index: Int) -> String? {
        let note = getStepNote(at: index)
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
