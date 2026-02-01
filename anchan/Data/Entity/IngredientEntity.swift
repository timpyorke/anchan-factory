import SwiftData
import Foundation

@Model
final class IngredientEntity {
    var quantity: Double            // 100
    var unit: InventoryUnit         // g
    var note: String?

    // relationships
    @Relationship
    var inventoryItem: InventoryEntity
    
    @Relationship(inverse: \RecipeEntity.ingredients)
     var recipe: RecipeEntity

    init(
        inventoryItem: InventoryEntity,
        quantity: Double,
        unit: InventoryUnit,
        note: String? = nil,
        recipe: RecipeEntity
    ) {
        self.inventoryItem = inventoryItem
        self.quantity = quantity
        self.unit = unit
        self.note = note
        self.recipe = recipe
    }

    /// Check if inventory has enough stock for this ingredient
    var hasEnoughStock: Bool {
        inventoryItem.stock >= quantity
    }

    /// How much is missing (negative means enough, positive means shortage)
    var shortage: Double {
        max(0, quantity - inventoryItem.stock)
    }
}
