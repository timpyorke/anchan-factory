import SwiftData
import Foundation

@Model
final class CustomUnitEntity {
    var symbol: String          // "cup", "tbsp"
    var name: String            // "Cup", "Tablespoon"
    var createdAt: Date

    init(symbol: String, name: String) {
        self.symbol = symbol.lowercased()
        self.name = name
        self.createdAt = Date.now
    }
}
