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

    // MARK: - Dependencies

    private var manufacturingRepository: ManufacturingRepository?
    private var inventoryRepository: InventoryRepository?
    private var modelContext: ModelContext?

    // MARK: - Computed

    var lowStockItems: [InventoryEntity] {
        allInventory.filter { $0.isLowStock }.sorted { $0.stockLevel < $1.stockLevel }
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.manufacturingRepository = ManufacturingRepository(modelContext: modelContext)
        self.inventoryRepository = InventoryRepository(modelContext: modelContext)
        loadData()
    }

    // MARK: - Actions

    func loadData() {
        // Use repository methods instead of filtering in ViewModel
        activeManufacturing = manufacturingRepository?.fetchActive() ?? []
        completedManufacturing = manufacturingRepository?.fetchCompleted() ?? []
        allInventory = inventoryRepository?.fetchAll() ?? []
    }

    func handleRecipeSelection(_ recipe: RecipeEntity) -> Bool {
        if recipe.hasEnoughInventory {
            return true  // Proceed
        } else {
            selectedRecipe = recipe
            return false  // Show warning
        }
    }

    func startManufacturing(with recipe: RecipeEntity) -> PersistentIdentifier {
        guard let modelContext else { fatalError("ModelContext not initialized") }

        let batchNumber = ManufacturingEntity.generateBatchNumber(
            existingBatches: activeManufacturing + completedManufacturing
        )
        let manufacturing = ManufacturingEntity(recipe: recipe, batchNumber: batchNumber)
        modelContext.insert(manufacturing)

        loadData()  // Refresh
        return manufacturing.persistentModelID
    }
}
