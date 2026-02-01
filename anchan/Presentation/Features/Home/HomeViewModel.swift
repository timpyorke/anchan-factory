import Observation

@Observable
final class HomeViewModel {
    var counter: Int = 0

    func increment() {
        counter += 1
    }
}
