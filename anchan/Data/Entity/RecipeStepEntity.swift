import SwiftData
import Foundation

@Model
final class RecipeStepEntity {

    var title: String
    var note: String
    var time: Int              // minutes
    var order: Int

    @Relationship(inverse: \RecipeEntity.steps)
    var recipe: RecipeEntity?

    init(
        title: String,
        note: String = "",
        time: Int = 0,
        order: Int = 0
    ) {
        self.title = title
        self.note = note
        self.time = time
        self.order = order
    }
}
