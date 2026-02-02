import SwiftData
import Foundation

protocol InventoryRepositoryProtocol {
    // Inventory CRUD
    func fetchAll() -> Result<[InventoryEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<InventoryEntity, AppError>
    func search(name: String) -> Result<[InventoryEntity], AppError>
    func create(_ item: InventoryEntity) -> Result<Void, AppError>
    func delete(_ item: InventoryEntity) -> Result<Void, AppError>

    // Ingredient operations
    func fetchIngredients(for inventory: InventoryEntity) -> Result<[IngredientEntity], AppError>
    func deleteIngredient(_ ingredient: IngredientEntity) -> Result<Void, AppError>
}

@MainActor
final class InventoryRepository: InventoryRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Inventory CRUD

    func fetchAll() -> Result<[InventoryEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<InventoryEntity>(
                sortBy: [SortDescriptor(\.name)]
            )
            let items = try modelContext.fetch(descriptor)
            return .success(items)
        } catch {
            return .failure(.databaseError("Failed to fetch inventory items"))
        }
    }

    func fetch(by id: PersistentIdentifier) -> Result<InventoryEntity, AppError> {
        guard let item = modelContext.model(for: id) as? InventoryEntity else {
            return .failure(.notFound("Inventory item"))
        }
        return .success(item)
    }

    func search(name: String) -> Result<[InventoryEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<InventoryEntity>(
                predicate: #Predicate { $0.name.localizedStandardContains(name) },
                sortBy: [SortDescriptor(\.name)]
            )
            let items = try modelContext.fetch(descriptor)
            return .success(items)
        } catch {
            return .failure(.databaseError("Failed to search inventory items"))
        }
    }

    func create(_ item: InventoryEntity) -> Result<Void, AppError> {
        modelContext.insert(item)
        return save()
    }

    func delete(_ item: InventoryEntity) -> Result<Void, AppError> {
        modelContext.delete(item)
        return save()
    }

    // MARK: - Ingredient Operations

    func fetchIngredients(for inventory: InventoryEntity) -> Result<[IngredientEntity], AppError> {
        do {
            let inventoryId = inventory.persistentModelID
            let descriptor = FetchDescriptor<IngredientEntity>(
                predicate: #Predicate { $0.inventoryItem.persistentModelID == inventoryId }
            )
            let ingredients = try modelContext.fetch(descriptor)
            return .success(ingredients)
        } catch {
            return .failure(.databaseError("Failed to fetch ingredients"))
        }
    }

    func deleteIngredient(_ ingredient: IngredientEntity) -> Result<Void, AppError> {
        modelContext.delete(ingredient)
        return save()
    }

    // MARK: - Private

    private func save() -> Result<Void, AppError> {
        do {
            try modelContext.save()
            return .success(())
        } catch {
            return .failure(.databaseError("Failed to save changes: \(error.localizedDescription)"))
        }
    }
}
