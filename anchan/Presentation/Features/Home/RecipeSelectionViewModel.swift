import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class RecipeSelectionViewModel {

    // MARK: - State

    private(set) var recipes: [RecipeEntity] = []
    var searchText: String = ""

    // MARK: - Dependencies

    private var repository: RecipeRepository?

    // MARK: - Computed

    var filteredRecipes: [RecipeEntity] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.repository = RecipeRepository(modelContext: modelContext)
        loadRecipes()
    }

    // MARK: - Actions

    func loadRecipes() {
        recipes = repository?.fetchAll() ?? []
    }
}
