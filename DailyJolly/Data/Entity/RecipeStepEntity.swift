import SwiftData
import Foundation

@Model
final class RecipeStepEntity {

    var title: String
    var note: String
    var time: Int              // minutes
    var order: Int
    var requiredMeasurementRawValues: [String] = []

    var requiredMeasurements: [MeasurementType] {
        get { requiredMeasurementRawValues.compactMap { MeasurementType(rawValue: $0) } }
        set { requiredMeasurementRawValues = newValue.map { $0.rawValue } }
    }

    @Relationship(inverse: \RecipeEntity.steps)
    var recipe: RecipeEntity?

    init(
        title: String,
        note: String = "",
        time: Int = 0,
        order: Int = 0,
        requiredMeasurements: [MeasurementType] = []
    ) {
        self.title = title
        self.note = note
        self.time = time
        self.order = order
        self.requiredMeasurements = requiredMeasurements
    }
}
