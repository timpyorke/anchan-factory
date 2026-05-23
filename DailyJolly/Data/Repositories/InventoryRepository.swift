import SwiftData
import Foundation

@MainActor
protocol InventoryRepositoryProtocol {
    // Inventory CRUD
    func fetchAll() -> Result<[InventoryEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<InventoryEntity, AppError>
    func search(name: String) -> Result<[InventoryEntity], AppError>
    func create(_ item: InventoryEntity) -> Result<Void, AppError>
    func delete(_ item: InventoryEntity) -> Result<Void, AppError>
    func recipesUsing(_ item: InventoryEntity) -> [RecipeEntity]

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
        // Refuse to delete when an ingredient still references this item;
        // SwiftData would leave the non-optional IngredientEntity.inventoryItem
        // dangling and crash the next time a recipe touches it.
        let usedBy = recipesUsing(item)
        if !usedBy.isEmpty {
            let names = usedBy.prefix(3).map(\.name).joined(separator: ", ")
            let suffix = usedBy.count > 3 ? " (+\(usedBy.count - 3) more)" : ""
            return .failure(.validationError("This item is used by: \(names)\(suffix). Remove it from those recipes first."))
        }

        modelContext.delete(item)
        return save()
    }

    func recipesUsing(_ item: InventoryEntity) -> [RecipeEntity] {
        let inventoryId = item.persistentModelID
        let descriptor = FetchDescriptor<IngredientEntity>(
            predicate: #Predicate { $0.inventoryItem.persistentModelID == inventoryId }
        )
        guard let ingredients = try? modelContext.fetch(descriptor) else { return [] }
        var seen: Set<PersistentIdentifier> = []
        var recipes: [RecipeEntity] = []
        for ingredient in ingredients {
            let recipe = ingredient.recipe
            if seen.insert(recipe.persistentModelID).inserted {
                recipes.append(recipe)
            }
        }
        return recipes
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
