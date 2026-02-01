import SwiftData
import Foundation

@Model
final class RecipeEntity {

    var name: String
    var note: String
    var category: String?
    var isFavorite: Bool
    var batchSize: Int = 1          // How many units this recipe produces
    var batchUnit: String = "pcs"   // Unit label for batch (e.g., "pcs", "bottles", "boxes")
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var ingredients: [IngredientEntity] = []

    @Relationship(deleteRule: .cascade)
    var steps: [RecipeStepEntity] = []

    init(
        name: String,
        note: String = "",
        category: String? = nil,
        batchSize: Int = 1,
        batchUnit: String = "pcs"
    ) {
        self.name = name
        self.note = note
        self.category = category
        self.isFavorite = false
        self.batchSize = batchSize
        self.batchUnit = batchUnit
        self.createdAt = Date.now
    }

    var totalTime: Int {
        steps.reduce(0) { $0 + $1.time }
    }

    var sortedSteps: [RecipeStepEntity] {
        steps.sorted { $0.order < $1.order }
    }

    /// Total cost for one batch of this recipe
    var totalCost: Double {
        ingredients.reduce(0.0) { total, ingredient in
            total + (ingredient.quantityInBaseUnit * ingredient.inventoryItem.unitPrice)
        }
    }

    /// Cost per single unit (totalCost / batchSize)
    var costPerUnit: Double {
        guard batchSize > 0 else { return totalCost }
        return totalCost / Double(batchSize)
    }

    /// Calculate total cost for multiple batches
    func cost(forBatches batches: Int) -> Double {
        totalCost * Double(batches)
    }

    /// Calculate total units produced for multiple batches
    func units(forBatches batches: Int) -> Int {
        batchSize * batches
    }

    /// Check if all ingredients have enough stock
    var hasEnoughInventory: Bool {
        ingredients.allSatisfy { $0.hasEnoughStock }
    }

    /// Get list of ingredients with insufficient stock
    var insufficientIngredients: [IngredientEntity] {
        ingredients.filter { !$0.hasEnoughStock }
    }

    /// Count of ingredients with insufficient stock
    var insufficientCount: Int {
        insufficientIngredients.count
    }
}
