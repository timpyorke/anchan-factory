import SwiftData
import Foundation

@Model
final class RecipeEntity {

    var name: String
    var note: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var ingredients: [IngredientEntity] = []

    init(name: String, note: String = "") {
        self.name = name
        self.note = note
        self.createdAt = Date.now
    }
}
