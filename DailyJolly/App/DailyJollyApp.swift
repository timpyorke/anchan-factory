import SwiftUI
import SwiftData

@main
struct DailyJollyApp: App {
    private let container = AppModelContainer.make()
    @State private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(settings.theme.colorScheme)
        }
        .modelContainer(container)
    }
}
