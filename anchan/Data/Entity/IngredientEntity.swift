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

    /// Quantity converted to the inventory's base unit
    var quantityInBaseUnit: Double {
        unit.convert(quantity, to: inventoryItem.baseUnit) ?? quantity
    }

    /// Check if inventory has enough stock for this ingredient
    var hasEnoughStock: Bool {
        inventoryItem.stock >= quantityInBaseUnit
    }

    /// How much is missing (in base unit) - zero means enough, positive means shortage
    var shortage: Double {
        max(0, quantityInBaseUnit - inventoryItem.stock)
    }
}
