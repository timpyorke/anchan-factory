import SwiftUI

struct RecipeView: View {
    let stackRouter: StackRouter
    @State private var viewModel = RecipeViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("RecipeView")
                .font(.largeTitle.bold())
        }
        .navigationTitle("RecipeView")
        
    }
}
