import SwiftUI
import Observation

@Observable
class Router {
    var path = NavigationPath()
    
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }
    
    func goBack() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
