import SwiftData
import Foundation

protocol InventoryRepositoryProtocol {
    // Inventory CRUD
    func fetchAll() -> [InventoryEntity]
    func fetch(by id: PersistentIdentifier) -> InventoryEntity?
    func search(name: String) -> [InventoryEntity]
    func create(_ item: InventoryEntity)
    func delete(_ item: InventoryEntity)

    // Ingredient operations
    func fetchIngredients(for inventory: InventoryEntity) -> [IngredientEntity]
    func deleteIngredient(_ ingredient: IngredientEntity)
}

@MainActor
final class InventoryRepository: InventoryRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Inventory CRUD

    func fetchAll() -> [InventoryEntity] {
        let descriptor = FetchDescriptor<InventoryEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetch(by id: PersistentIdentifier) -> InventoryEntity? {
        return modelContext.model(for: id) as? InventoryEntity
    }

    func search(name: String) -> [InventoryEntity] {
        let descriptor = FetchDescriptor<InventoryEntity>(
            predicate: #Predicate { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func create(_ item: InventoryEntity) {
        modelContext.insert(item)
        save()
    }

    func delete(_ item: InventoryEntity) {
        modelContext.delete(item)
        save()
    }

    // MARK: - Ingredient Operations

    func fetchIngredients(for inventory: InventoryEntity) -> [IngredientEntity] {
        let inventoryId = inventory.persistentModelID
        let descriptor = FetchDescriptor<IngredientEntity>(
            predicate: #Predicate { $0.inventoryItem.persistentModelID == inventoryId }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteIngredient(_ ingredient: IngredientEntity) {
        modelContext.delete(ingredient)
        save()
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("[InventoryRepository] Save error: \(error)")
        }
    }
}
