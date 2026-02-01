import SwiftData
import Foundation

@Model
final class InventoryEntity {

    var name: String               // "Sugar"
    var category: String?          // "Baking"
    var baseUnit: InventoryUnit    // g, ml, piece
    var unitPrice: Double          // price per base unit
    var stock: Double              // current stock
    var createdAt: Date

    init(
        name: String,
        baseUnit: InventoryUnit,
        unitPrice: Double,
        stock: Double
    ) {
        self.name = name
        self.baseUnit = baseUnit
        self.unitPrice = unitPrice
        self.stock = stock
        self.createdAt = Date()
    }
}
