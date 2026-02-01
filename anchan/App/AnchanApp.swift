import SwiftUI
import SwiftData

@main
struct AnchanApp: App {
    private let container = AppModelContainer.make()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(container)
    }
}
