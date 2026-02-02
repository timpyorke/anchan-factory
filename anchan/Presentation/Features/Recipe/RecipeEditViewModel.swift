import Foundation
import SwiftUI
import Observation
import SwiftData

@Observable
@MainActor
final class RecipeEditViewModel {

    // MARK: - State Properties

    private(set) var recipe: RecipeEntity?
    var name: String = ""
    var note: String = ""
    var category: String = ""
    var batchSize: Int = 1
    var batchUnit: String = "pcs"
    var steps: [StepInput] = []
    var ingredients: [IngredientInput] = []

    // MARK: - UI State

    var isAddingStep: Bool = false
    var isAddingIngredient: Bool = false
    var showDeleteAlert: Bool = false

    // MARK: - Dependencies

    private var repository: RecipeRepository?
    private var inventoryRepository: InventoryRepository?
    private var modelContext: ModelContext?

    // MARK: - Computed Properties

    var isEditing: Bool { recipe != nil }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var totalTime: Int {
        steps.reduce(0) { $0 + $1.time }
    }

    var totalCost: Double {
        calculateTotalCost()
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext, recipeId: PersistentIdentifier?) {
        self.modelContext = modelContext
        self.repository = RecipeRepository(modelContext: modelContext)
        self.inventoryRepository = InventoryRepository(modelContext: modelContext)

        if let id = recipeId {
            loadRecipe(id: id)
        }
    }

    // MARK: - Actions

    func loadRecipe(id: PersistentIdentifier) {
        recipe = repository?.fetch(by: id)

        guard let recipe else { return }
        name = recipe.name
        note = recipe.note
        category = recipe.category ?? ""
        batchSize = recipe.batchSize
        batchUnit = recipe.batchUnit
        steps = recipe.sortedSteps.map { step in
            StepInput(title: step.title, note: step.note, time: step.time)
        }
        ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(
                inventoryId: ingredient.inventoryItem.persistentModelID,
                inventoryName: ingredient.inventoryItem.name,
                quantity: ingredient.quantity,
                unitSymbol: ingredient.unitSymbol,
                note: ingredient.note ?? ""
            )
        }
    }

    func saveRecipe(onComplete: () -> Void) {
        guard let modelContext else { return }

        if let recipe {
            // Update existing recipe
            repository?.updateBasicInfo(
                recipe,
                name: name,
                note: note,
                category: category.isEmpty ? nil : category,
                batchSize: batchSize,
                batchUnit: batchUnit
            )

            // Rebuild relationships
            let recipeSteps = steps.map { step in
                RecipeStepInput(title: step.title, note: step.note, time: step.time)
            }
            let recipeIngredients = ingredients.map { ingredient in
                RecipeIngredientInput(
                    inventoryId: ingredient.inventoryId,
                    quantity: ingredient.quantity,
                    unitSymbol: ingredient.unitSymbol,
                    note: ingredient.note.isEmpty ? nil : ingredient.note
                )
            }
            repository?.rebuildRelationships(recipe, steps: recipeSteps, ingredients: recipeIngredients)
        } else {
            // Create new recipe
            let newRecipe = RecipeEntity(
                name: name.trimmingCharacters(in: .whitespaces),
                note: note,
                category: category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces),
                batchSize: batchSize,
                batchUnit: batchUnit.isEmpty ? "pcs" : batchUnit.trimmingCharacters(in: .whitespaces)
            )

            // Add steps
            for (index, stepInput) in steps.enumerated() {
                let step = RecipeStepEntity(
                    title: stepInput.title,
                    note: stepInput.note,
                    time: stepInput.time,
                    order: index
                )
                step.recipe = newRecipe
                newRecipe.steps.append(step)
            }

            // Add ingredients
            for ingredientInput in ingredients {
                if let inventory = modelContext.model(for: ingredientInput.inventoryId) as? InventoryEntity {
                    let ingredient = IngredientEntity(
                        inventoryItem: inventory,
                        quantity: ingredientInput.quantity,
                        unitSymbol: ingredientInput.unitSymbol,
                        note: ingredientInput.note.isEmpty ? nil : ingredientInput.note,
                        recipe: newRecipe
                    )
                    newRecipe.ingredients.append(ingredient)
                }
            }

            repository?.create(newRecipe)
        }

        onComplete()
    }

    func deleteRecipe(onComplete: () -> Void) {
        guard let recipe else { return }
        repository?.delete(recipe)
        onComplete()
    }

    func addStep(_ step: StepInput) {
        steps.append(step)
    }

    func removeStep(at index: Int) {
        steps.remove(at: index)
    }

    func moveSteps(from: IndexSet, to: Int) {
        steps.move(fromOffsets: from, toOffset: to)
    }

    func addIngredient(_ ingredient: IngredientInput) {
        ingredients.append(ingredient)
    }

    func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }

    // MARK: - Private Helpers

    private func calculateTotalCost() -> Double {
        guard let modelContext else { return 0.0 }

        return ingredients.reduce(0.0) { total, ingredient in
            if let inventory = modelContext.model(for: ingredient.inventoryId) as? InventoryEntity {
                // Try to convert if both are built-in units
                var quantityInBaseUnit = ingredient.quantity
                if let fromUnit = InventoryUnit(rawValue: ingredient.unitSymbol.lowercased()),
                   let toUnit = inventory.builtInUnit,
                   let converted = fromUnit.convert(ingredient.quantity, to: toUnit) {
                    quantityInBaseUnit = converted
                }
                return total + (quantityInBaseUnit * inventory.unitPrice)
            }
            return total
        }
    }
}
