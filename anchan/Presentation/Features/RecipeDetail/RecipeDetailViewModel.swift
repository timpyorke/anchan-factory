import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class RecipeDetailViewModel {

    // MARK: - State

    private(set) var recipe: RecipeEntity?

    // MARK: - UI State

    var showDeleteAlert = false

    // MARK: - Dependencies

    private var repository: RecipeRepository?

    // MARK: - Setup

    func setup(modelContext: ModelContext, recipeId: PersistentIdentifier) {
        self.repository = RecipeRepository(modelContext: modelContext)
        loadRecipe(id: recipeId)
    }

    // MARK: - Actions

    func loadRecipe(id: PersistentIdentifier) {
        recipe = repository?.fetch(by: id)
    }

    func deleteRecipe(onComplete: () -> Void) {
        guard let recipe else { return }
        repository?.delete(recipe)
        onComplete()
    }

    func toggleFavorite() {
        recipe?.isFavorite.toggle()
    }
}
