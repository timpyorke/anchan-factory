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
            print("[ManufacturingViewModel] Failed to load manufacturing: \(error)")
            manufacturing = nil
        }
    }

    func completeCurrentStep(note: String = "") {
        guard let manufacturing = manufacturing, let repository = repository else {
            print("[ManufacturingViewModel] ERROR: missing manufacturing or repository")
            return
        }

        let stepIndex = manufacturing.currentStepIndex
        print("[ManufacturingViewModel] Completing step \(stepIndex) with note: \(note)")

        manufacturing.completeCurrentStep(note: note)

        let isCompleted = manufacturing.isCompleted
        print("[ManufacturingViewModel] After completion - isCompleted: \(isCompleted)")

        // Deduct inventory if completed
        if isCompleted {
            deductInventory(for: manufacturing)
        }

        // Save the changes to the database
        switch repository.update() {
        case .success:
            print("[ManufacturingViewModel] ✅ Successfully saved to database")
            if isCompleted {
                showCompletionAlert = true
            }
        case .failure(let error):
            print("[ManufacturingViewModel] ❌ Failed to save: \(error)")
            handleError(error)
        }
    }

    private func deductInventory(for manufacturing: ManufacturingEntity) {
        print("[ManufacturingViewModel] 📦 Deducting inventory for \(manufacturing.quantity) batch(es)")

        let recipe = manufacturing.recipe
        for ingredient in recipe.ingredients {
            let quantityToDeduct = ingredient.quantityInBaseUnit * Double(manufacturing.quantity)
            let inventoryItem = ingredient.inventoryItem
            let oldStock = inventoryItem.stock

            inventoryItem.stock -= quantityToDeduct

            print("[ManufacturingViewModel]   - \(inventoryItem.name): \(oldStock) → \(inventoryItem.stock) \(inventoryItem.displaySymbol) (-\(quantityToDeduct))")
        }

        print("[ManufacturingViewModel] ✅ Inventory deducted successfully")
    }

    func cancelManufacturing(onComplete: () -> Void) {
        guard let manufacturing, let repository else { return }
        manufacturing.status = .cancelled

        // Save the changes to the database
        switch repository.update() {
        case .success:
            onComplete()
        case .failure(let error):
            handleError(error)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
