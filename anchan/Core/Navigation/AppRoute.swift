import Foundation
import SwiftData

enum AppRoute: Hashable {
    case recipeDetail(id: PersistentIdentifier)
    case recipeEdit(id: PersistentIdentifier)
    case recipeAdd
}
