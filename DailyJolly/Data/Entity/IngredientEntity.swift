import SwiftData
import Foundation

@Model
final class IngredientEntity {
    var quantity: Double            // 100
    var unitSymbol: String          // "g", "ml", or custom
    var note: String?

    // relationships
    @Relationship
    var inventoryItem: InventoryEntity

    @Relationship(inverse: \RecipeEntity.ingredients)
     var recipe: RecipeEntity

    init(
        inventoryItem: InventoryEntity,
        quantity: Double,
        unitSymbol: String,
        note: String? = nil,
        recipe: RecipeEntity
    ) {
        self.inventoryItem = inventoryItem
        self.quantity = quantity
        self.unitSymbol = unitSymbol
        self.note = note
        self.recipe = recipe
    }

    /// Display symbol (uppercase)
    var displaySymbol: String {
        unitSymbol.uppercased()
    }

    /// Quantity converted to the inventory's base unit
    var quantityInBaseUnit: Double {
        // Try to convert if both are built-in units
        if let fromUnit = InventoryUnit(rawValue: unitSymbol.lowercased()),
           let toUnit = inventoryItem.builtInUnit,
           let converted = fromUnit.convert(quantity, to: toUnit) {
            return converted
        }
        // Same unit or custom units - no conversion
        return quantity
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
