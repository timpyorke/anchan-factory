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
    var isLoading = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var repository: ManufacturingRepository?

    // MARK: - Setup

    func setup(modelContext: ModelContext, id: PersistentIdentifier) {
        self.repository = ManufacturingRepository(modelContext: modelContext)
        loadManufacturing(id: id)
    }

    // MARK: - Actions

    func loadManufacturing(id: PersistentIdentifier) {
        guard let repository else { return }

        isLoading = true
        defer { isLoading = false }

        switch repository.fetch(by: id) {
        case .success(let item):
            manufacturing = item
        case .failure(let error):
            handleError(error)
        }
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

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
