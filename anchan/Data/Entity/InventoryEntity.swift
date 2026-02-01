import SwiftData
import Foundation

@Model
final class InventoryEntity {

    var name: String               // "Sugar"
    var category: String?          // "Baking"
    var unitSymbol: String         // "g", "ml", "pcs", or custom like "cup"
    var unitPrice: Double          // price per base unit
    var stock: Double              // current stock
    var minStock: Double = 0       // minimum stock threshold for restock alert
    var createdAt: Date

    init(
        name: String,
        unitSymbol: String,
        unitPrice: Double,
        stock: Double,
        minStock: Double = 0
    ) {
        self.name = name
        self.unitSymbol = unitSymbol
        self.unitPrice = unitPrice
        self.stock = stock
        self.minStock = minStock
        self.createdAt = Date()
    }

    /// Get the InventoryUnit if it's a built-in unit, nil for custom units
    var builtInUnit: InventoryUnit? {
        InventoryUnit(rawValue: unitSymbol.lowercased())
    }

    /// Display symbol (uppercase)
    var displaySymbol: String {
        unitSymbol.uppercased()
    }

    /// Check if stock is below minimum threshold
    var isLowStock: Bool {
        minStock > 0 && stock < minStock
    }

    /// How much to restock to reach minimum
    var restockAmount: Double {
        max(0, minStock - stock)
    }

    /// Stock level as percentage of minimum (capped at 100%)
    var stockLevel: Double {
        guard minStock > 0 else { return 1.0 }
        return min(1.0, stock / minStock)
    }
}
