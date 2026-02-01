import SwiftUI

struct HomeView: View {
    let tabRouter: TabRouter
    let stackRouter: StackRouter
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Home")
                .font(.largeTitle.bold())
            
            Button("Go to Inventory") {
                tabRouter.go(to: .inventory)
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Home")
        
    }
}
