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
    var isLoading = false
    var isDeleting = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var repository: RecipeRepository?

    // MARK: - Setup

    func setup(modelContext: ModelContext, recipeId: PersistentIdentifier) {
        self.repository = RecipeRepository(modelContext: modelContext)
        loadRecipe(id: recipeId)
    }

    // MARK: - Actions

    func loadRecipe(id: PersistentIdentifier) {
        guard let repository else { return }

        isLoading = true
        defer { isLoading = false }

        switch repository.fetch(by: id) {
        case .success(let fetchedRecipe):
            recipe = fetchedRecipe
        case .failure(let error):
            print("[RecipeDetailViewModel] Failed to load recipe: \(error)")
            recipe = nil
        }
    }

    func deleteRecipe(onComplete: () -> Void) {
        guard let recipe, let repository else { return }

        isDeleting = true
        defer { isDeleting = false }

        switch repository.delete(recipe) {
        case .success:
            onComplete()
        case .failure(let error):
            handleError(error)
        }
    }

    func toggleFavorite() {
        recipe?.isFavorite.toggle()
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
