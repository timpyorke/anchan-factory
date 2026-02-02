import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class HomeViewModel {

    // MARK: - State

    private(set) var activeManufacturing: [ManufacturingEntity] = []
    private(set) var completedManufacturing: [ManufacturingEntity] = []
    private(set) var allInventory: [InventoryEntity] = []
    var selectedRecipe: RecipeEntity?

    // MARK: - UI State

    var showRecipeSelection = false
    var showInsufficientAlert = false
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var manufacturingRepository: ManufacturingRepository?
    private var inventoryRepository: InventoryRepository?

    // MARK: - Computed

    var lowStockItems: [InventoryEntity] {
        allInventory.filter { $0.isLowStock }.sorted { $0.stockLevel < $1.stockLevel }
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.manufacturingRepository = ManufacturingRepository(modelContext: modelContext)
        self.inventoryRepository = InventoryRepository(modelContext: modelContext)
        loadData()
    }

    // MARK: - Actions

    func loadData() {
        isLoading = true
        defer { isLoading = false }

        // Fetch active manufacturing
        if let result = manufacturingRepository?.fetchActive() {
            switch result {
            case .success(let items):
                activeManufacturing = items
            case .failure(let error):
                handleError(error)
            }
        }

        // Fetch completed manufacturing
        if let result = manufacturingRepository?.fetchCompleted() {
            switch result {
            case .success(let items):
                completedManufacturing = items
            case .failure(let error):
                handleError(error)
            }
        }

        // Fetch inventory
        if let result = inventoryRepository?.fetchAll() {
            switch result {
            case .success(let items):
                allInventory = items
            case .failure(let error):
                handleError(error)
            }
        }
    }

    func handleRecipeSelection(_ recipe: RecipeEntity) -> Bool {
        if recipe.hasEnoughInventory {
            return true  // Proceed
        } else {
            selectedRecipe = recipe
            return false  // Show warning
        }
    }

    func startManufacturing(with recipe: RecipeEntity) -> PersistentIdentifier? {
        guard let manufacturingRepository else { return nil }

        isSaving = true
        defer { isSaving = false }

        let batchNumber = ManufacturingEntity.generateBatchNumber(
            existingBatches: activeManufacturing + completedManufacturing
        )
        let manufacturing = ManufacturingEntity(recipe: recipe, batchNumber: batchNumber)

        switch manufacturingRepository.create(manufacturing) {
        case .success:
            loadData()
            return manufacturing.persistentModelID
        case .failure(let error):
            handleError(error)
            return nil
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
