import Foundation
import SwiftData

enum AppRoute: Hashable {
    case recipeDetail(id: PersistentIdentifier)
    case recipeEdit(id: PersistentIdentifier)
    case recipeAdd

    // Manufacturing
    case manufacturingProcess(id: PersistentIdentifier)
    case manufacturingDetail(id: PersistentIdentifier)
}
