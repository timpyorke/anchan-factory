import Observation
import SwiftUI

@Observable
final class StackRouter {

    var path: [AppRoute] = []

    // Push
    func push(_ route: AppRoute) {
        path.append(route)
    }

    // Pop 1
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // Pop to root
    func popToRoot() {
        path.removeAll()
    }
}
