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
}
