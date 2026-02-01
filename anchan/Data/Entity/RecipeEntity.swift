import SwiftData
import Foundation

@Model
final class RecipeEntity {

    var name: String
    var note: String
    var category: String?
    var isFavorite: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var ingredients: [IngredientEntity] = []

    @Relationship(deleteRule: .cascade)
    var steps: [RecipeStepEntity] = []

    init(
        name: String,
        note: String = "",
        category: String? = nil
    ) {
        self.name = name
        self.note = note
        self.category = category
        self.isFavorite = false
        self.createdAt = Date.now
    }

    var totalTime: Int {
        steps.reduce(0) { $0 + $1.time }
    }

    var sortedSteps: [RecipeStepEntity] {
        steps.sorted { $0.order < $1.order }
    }

    var totalCost: Double {
        ingredients.reduce(0.0) { total, ingredient in
            total + (ingredient.quantity * ingredient.inventoryItem.unitPrice)
        }
    }
}
