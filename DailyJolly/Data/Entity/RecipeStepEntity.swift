import SwiftData
import Foundation

@Model
final class RecipeStepEntity {

    var title: String
    var note: String
    var time: Int              // minutes
    var isTimerRequired: Bool = false
    var order: Int
    var requiredMeasurementRawValues: [String] = []
    var lineIdentifier: String? // "Line A", "Line B"

    @Relationship
    var dependencies: [RecipeStepEntity] = []

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
        isTimerRequired: Bool = false,
        order: Int = 0,
        requiredMeasurements: [MeasurementType] = [],
        lineIdentifier: String? = nil,
        dependencies: [RecipeStepEntity] = []
    ) {
        self.title = title
        self.note = note
        self.time = time
        self.isTimerRequired = isTimerRequired
        self.order = order
        self.requiredMeasurementRawValues = []
        self.lineIdentifier = lineIdentifier
        self.dependencies = dependencies
        // Now set computed property
        self.requiredMeasurements = requiredMeasurements
    }

    /// Create a clone of this step for a new recipe
    func clone(for recipe: RecipeEntity) -> RecipeStepEntity {
        let newStep = RecipeStepEntity(
            title: title,
            note: note,
            time: time,
            isTimerRequired: isTimerRequired,
            order: order,
            requiredMeasurements: requiredMeasurements,
            lineIdentifier: lineIdentifier
        )
        newStep.recipe = recipe
        return newStep
    }
}
