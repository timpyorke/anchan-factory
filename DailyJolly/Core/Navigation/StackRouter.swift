import Observation
import SwiftUI

@Observable
final class StackRouter {

    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    func popToRoot() {
        path.removeAll()
    }
}
