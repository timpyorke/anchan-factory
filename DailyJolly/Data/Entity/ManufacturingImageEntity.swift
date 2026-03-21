import SwiftData
import Foundation

@Model
final class ManufacturingImageEntity {
    @Attribute(.externalStorage)
    var imageData: Data
    var createdAt: Date = Date.now
    
    @Relationship(inverse: \ManufacturingEntity.images)
    var manufacturing: ManufacturingEntity?
    
    init(imageData: Data, manufacturing: ManufacturingEntity? = nil) {
        self.imageData = imageData
        self.manufacturing = manufacturing
        self.createdAt = Date.now
    }
}
