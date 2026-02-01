import SwiftData
import Foundation

@Model
final class RecipeEntity {
    var name: String

    init(
        name: String,
    ) {
        self.name = name
    }
}

