import SwiftUI

enum AppTab: Hashable {
    case home
    case recipe
    case inventory
    case setting

    var title: String {
        switch self {
        case .home: return String(localized: "Home")
        case .recipe: return String(localized: "Recipe")
        case .inventory: return String(localized: "Inventory")
        case .setting: return String(localized: "Setting")
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
