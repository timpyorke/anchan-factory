import SwiftUI

struct ContentView: View {
    @State private var router = Router()
    
    var body: some View {
        NavigationStack(
            path: $router.path
        ) {
            HomeView()
                .navigationDestination(
                    for: AppScreen.self
                ) { screen in
                    switch screen {
                    case .home: HomeView()
                    case .detail(
                        let name
                    ): DetailView(
                        productName: name
                    )
                    case .settings: SettingsView()
                    }
                }
        }
        .environment(
            router
        )
    }
}
