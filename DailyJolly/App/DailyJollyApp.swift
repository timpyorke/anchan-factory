import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct DailyJollyApp: App {
    private let container = AppModelContainer.make()
    @State private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(settings.theme.colorScheme)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(container)
    }
}
