import SwiftData
import Foundation

@MainActor
protocol RecipeRepositoryProtocol {
    func fetchAll() -> Result<[RecipeEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<RecipeEntity, AppError>
    func search(name: String) -> Result<[RecipeEntity], AppError>
    func fetchFavorites() -> Result<[RecipeEntity], AppError>
    func fetchByCategory(_ category: String) -> Result<[RecipeEntity], AppError>
    func create(_ recipe: RecipeEntity) -> Result<Void, AppError>
    func delete(_ recipe: RecipeEntity) -> Result<Void, AppError>
    func updateBasicInfo(_ recipe: RecipeEntity, name: String, note: String, category: String?, batchSize: Int, batchUnit: String) -> Result<Void, AppError>
    func rebuildRelationships(_ recipe: RecipeEntity, steps: [RecipeStepInput], ingredients: [RecipeIngredientInput]) -> Result<Void, AppError>
}

// MARK: - Input Models for Recipe Updates

struct RecipeStepInput {
    let title: String
    let note: String
    let time: Int
}

struct RecipeIngredientInput {
    let inventoryId: PersistentIdentifier
    let quantity: Double
    let unitSymbol: String
    let note: String?
}

@MainActor
final class RecipeRepository: RecipeRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() -> Result<[RecipeEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<RecipeEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let recipes = try modelContext.fetch(descriptor)
            return .success(recipes)
        } catch {
            return .failure(.databaseError("Failed to fetch recipes"))
        }
    }

    func fetch(by id: PersistentIdentifier) -> Result<RecipeEntity, AppError> {
        guard let recipe = modelContext.model(for: id) as? RecipeEntity else {
            return .failure(.notFound("Recipe"))
        }
        return .success(recipe)
    }

    func search(name: String) -> Result<[RecipeEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<RecipeEntity>(
                predicate: #Predicate { $0.name.localizedStandardContains(name) },
                sortBy: [SortDescriptor(\.name)]
            )
            let recipes = try modelContext.fetch(descriptor)
            return .success(recipes)
        } catch {
            return .failure(.databaseError("Failed to search recipes"))
        }
    }

    func fetchFavorites() -> Result<[RecipeEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<RecipeEntity>(
                predicate: #Predicate { $0.isFavorite },
                sortBy: [SortDescriptor(\.name)]
            )
            let recipes = try modelContext.fetch(descriptor)
            return .success(recipes)
        } catch {
            return .failure(.databaseError("Failed to fetch favorite recipes"))
        }
    }

    func fetchByCategory(_ category: String) -> Result<[RecipeEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<RecipeEntity>(
                predicate: #Predicate { $0.category == category },
                sortBy: [SortDescriptor(\.name)]
            )
            let recipes = try modelContext.fetch(descriptor)
            return .success(recipes)
        } catch {
            return .failure(.databaseError("Failed to fetch recipes by category"))
        }
    }

    // MARK: - Create & Delete

    func create(_ recipe: RecipeEntity) -> Result<Void, AppError> {
        modelContext.insert(recipe)
        return save()
    }

    func delete(_ recipe: RecipeEntity) -> Result<Void, AppError> {
        modelContext.delete(recipe)
        return save()
    }

    // MARK: - Update

    func updateBasicInfo(_ recipe: RecipeEntity, name: String, note: String, category: String?, batchSize: Int, batchUnit: String) -> Result<Void, AppError> {
        recipe.name = name.trimmingCharacters(in: .whitespaces)
        recipe.note = note
        recipe.category = category?.isEmpty == false ? category?.trimmingCharacters(in: .whitespaces) : nil
        recipe.batchSize = batchSize
        recipe.batchUnit = batchUnit.isEmpty ? "pcs" : batchUnit.trimmingCharacters(in: .whitespaces)
        return save()
    }

    func rebuildRelationships(_ recipe: RecipeEntity, steps: [RecipeStepInput], ingredients: [RecipeIngredientInput]) -> Result<Void, AppError> {
        // Remove old steps
        for step in recipe.steps {
            modelContext.delete(step)
        }
        recipe.steps.removeAll()

        // Remove old ingredients
        for ingredient in recipe.ingredients {
            modelContext.delete(ingredient)
        }
        recipe.ingredients.removeAll()

        // Add new steps
        for (index, stepInput) in steps.enumerated() {
            let step = RecipeStepEntity(
                title: stepInput.title,
                note: stepInput.note,
                time: stepInput.time,
                order: index
            )
            step.recipe = recipe
            recipe.steps.append(step)
        }

        // Add new ingredients
        for ingredientInput in ingredients {
            if let inventory = modelContext.model(for: ingredientInput.inventoryId) as? InventoryEntity {
                let ingredient = IngredientEntity(
                    inventoryItem: inventory,
                    quantity: ingredientInput.quantity,
                    unitSymbol: ingredientInput.unitSymbol,
                    note: ingredientInput.note,
                    recipe: recipe
                )
                recipe.ingredients.append(ingredient)
            }
        }

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
