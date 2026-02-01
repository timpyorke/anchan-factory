import SwiftUI

enum AppTab: Hashable {
    case home
    case recipe
    case inventory
    case setting

    var title: String {
        switch self {
        case .home: return "Home"
        case .recipe: return "Recipe"
        case .inventory: return "Inventory"
        case .setting: return "Setting"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .recipe: return "book"
        case .inventory: return "archivebox"
        case .setting: return "gearshape"
        }
    }
}
