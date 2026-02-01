import SwiftUI

struct RecipeDetailView: View {
    let id: UUID
    
    var body: some View {
        VStack(spacing: 16) {
            Text("RecipeDetailView")
                .font(.largeTitle.bold())
        }
        .navigationTitle("RecipeDetailView")
        
    }
}

