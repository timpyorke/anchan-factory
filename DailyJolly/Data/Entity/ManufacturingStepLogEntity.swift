import SwiftData
import Foundation

@Model
final class ManufacturingStepLogEntity {
    var stepIndex: Int
    var note: String = ""
    var startedAt: Date?
    var completedAt: Date?
    var createdAt: Date = Date.now

    @Relationship(inverse: \ManufacturingEntity.stepLogs)
    var manufacturing: ManufacturingEntity?

    init(stepIndex: Int, note: String = "", startedAt: Date? = nil, completedAt: Date? = nil, manufacturing: ManufacturingEntity? = nil) {
        self.stepIndex = stepIndex
        self.note = note
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.manufacturing = manufacturing
        self.createdAt = Date.now
    }
}
