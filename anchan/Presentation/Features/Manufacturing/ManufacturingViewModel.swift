import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class ManufacturingViewModel {

    // MARK: - State

    private(set) var manufacturing: ManufacturingEntity?

    // MARK: - UI State

    var showCancelAlert = false
    var showCompletionAlert = false

    // MARK: - Dependencies

    private var repository: ManufacturingRepository?

    // MARK: - Setup

    func setup(modelContext: ModelContext, id: PersistentIdentifier) {
        self.repository = ManufacturingRepository(modelContext: modelContext)
        loadManufacturing(id: id)
    }

    // MARK: - Actions

    func loadManufacturing(id: PersistentIdentifier) {
        manufacturing = repository?.fetch(by: id)
    }

    func completeCurrentStep() {
        guard let manufacturing else { return }
        manufacturing.completeCurrentStep()

        if manufacturing.isCompleted {
            showCompletionAlert = true
        }
    }

    func cancelManufacturing(onComplete: () -> Void) {
        guard let manufacturing else { return }
        manufacturing.status = .cancelled
        onComplete()
    }
}
