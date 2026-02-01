import SwiftData
import Foundation

@Model
final class RecipeEntity {
    var name: String

    @Relationship(deleteRule: .cascade)
    var ingredients: [IngredientEntity]?

    init(
        name: String,
        ingredients: [IngredientEntity] = []
    ) {
        self.name = name
        self.ingredients = ingredients
    }
}

