import SwiftData
import Foundation

protocol RecipeRepositoryProtocol {
    func fetchAll() -> [RecipeEntity]
    func fetch(by id: PersistentIdentifier) -> RecipeEntity?
    func search(name: String) -> [RecipeEntity]
    func fetchFavorites() -> [RecipeEntity]
    func fetchByCategory(_ category: String) -> [RecipeEntity]
    func create(_ recipe: RecipeEntity)
    func delete(_ recipe: RecipeEntity)
    func updateBasicInfo(_ recipe: RecipeEntity, name: String, note: String, category: String?, batchSize: Int, batchUnit: String)
    func rebuildRelationships(_ recipe: RecipeEntity, steps: [RecipeStepInput], ingredients: [RecipeIngredientInput])
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

    func fetchAll() -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetch(by id: PersistentIdentifier) -> RecipeEntity? {
        return modelContext.model(for: id) as? RecipeEntity
    }

    func search(name: String) -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchFavorites() -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchByCategory(_ category: String) -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Create & Delete

    func create(_ recipe: RecipeEntity) {
        modelContext.insert(recipe)
        save()
    }

    func delete(_ recipe: RecipeEntity) {
        modelContext.delete(recipe)
        save()
    }

    // MARK: - Update

    func updateBasicInfo(_ recipe: RecipeEntity, name: String, note: String, category: String?, batchSize: Int, batchUnit: String) {
        recipe.name = name.trimmingCharacters(in: .whitespaces)
        recipe.note = note
        recipe.category = category?.isEmpty == false ? category?.trimmingCharacters(in: .whitespaces) : nil
        recipe.batchSize = batchSize
        recipe.batchUnit = batchUnit.isEmpty ? "pcs" : batchUnit.trimmingCharacters(in: .whitespaces)
        save()
    }

    func rebuildRelationships(_ recipe: RecipeEntity, steps: [RecipeStepInput], ingredients: [RecipeIngredientInput]) {
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

        save()
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("[RecipeRepository] Save error: \(error)")
        }
    }
}
