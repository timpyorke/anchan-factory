import Foundation
import SwiftData

enum AppRoute: Hashable {
    case recipeAdd
    case recipeEdit(id: PersistentIdentifier)
    case recipeDetail(id: PersistentIdentifier)
    case manufacturingList
    case manufacturingProcess(id: PersistentIdentifier)
    case manufacturingDetail(id: PersistentIdentifier)
}
