import SwiftData
import Foundation

@Model
final class MeasurementLogEntity {
    var typeRawValue: String
    var value: Double
    var timestamp: Date
    var stepIndex: Int
    
    @Relationship(inverse: \ManufacturingEntity.measurements)
    var manufacturing: ManufacturingEntity?
    
    var type: MeasurementType {
        get { MeasurementType(rawValue: typeRawValue) ?? .temp }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(type: MeasurementType, value: Double, stepIndex: Int, manufacturing: ManufacturingEntity) {
        self.typeRawValue = type.rawValue
        self.value = value
        self.timestamp = Date.now
        self.stepIndex = stepIndex
        self.manufacturing = manufacturing
    }
}
