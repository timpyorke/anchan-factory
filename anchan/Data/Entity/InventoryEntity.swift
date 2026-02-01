import SwiftData
import Foundation

@Model
final class InventoryEntity {
    var name: String

    init(
        name: String,
    ) {
        self.name = name
    }
}
