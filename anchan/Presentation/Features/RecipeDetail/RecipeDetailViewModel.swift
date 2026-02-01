import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class RecipeDetailViewModel {
    
    // MARK: - Dependencies
    private var repository: RecipeRepository?
    
    func setup(modelContext: ModelContext) {
        self.repository = RecipeRepository(modelContext: modelContext)
    }
}
