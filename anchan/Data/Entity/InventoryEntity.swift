import SwiftData
import Foundation

@Model
final class InventoryEntity {

    var name: String               // "Sugar"
    var category: String?          // "Baking"
    var baseUnit: InventoryUnit    // g, ml, piece
    var unitPrice: Double          // price per base unit
    var stock: Double              // current stock
    var minStock: Double = 0       // minimum stock threshold for restock alert
    var createdAt: Date

    init(
        name: String,
        baseUnit: InventoryUnit,
        unitPrice: Double,
        stock: Double,
        minStock: Double = 0
    ) {
        self.name = name
        self.baseUnit = baseUnit
        self.unitPrice = unitPrice
        self.stock = stock
        self.minStock = minStock
        self.createdAt = Date()
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
