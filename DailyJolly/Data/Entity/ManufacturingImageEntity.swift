import SwiftData
import Foundation

@Model
final class ManufacturingImageEntity {
    @Attribute(.externalStorage)
    var imageData: Data
    var stepIndex: Int?        // Associated step index (nil for final work result)
    var createdAt: Date = Date.now
    
    @Relationship(inverse: \ManufacturingEntity.images)
    var manufacturing: ManufacturingEntity?
    
    init(imageData: Data, stepIndex: Int? = nil, manufacturing: ManufacturingEntity? = nil) {
        self.imageData = imageData
        self.stepIndex = stepIndex
        self.manufacturing = manufacturing
        self.createdAt = Date.now
    }
}
