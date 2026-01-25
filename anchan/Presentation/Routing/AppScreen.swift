import Foundation

enum AppScreen: Hashable {
    case home
    case detail(productName: String)
    case settings
}
