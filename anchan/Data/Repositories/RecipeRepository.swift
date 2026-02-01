import SwiftData
import Foundation

protocol RecipeRepositoryProtocol {
    func fetchAll() -> [RecipeEntity]
    func fetch(by id: PersistentIdentifier) -> RecipeEntity?
    func search(name: String) -> [RecipeEntity]
    func fetchFavorites() -> [RecipeEntity]
    func fetchByCategory(_ category: String) -> [RecipeEntity]
    func create(_ recipe: RecipeEntity)
    func delete(_ recipe: RecipeEntity)
}

@MainActor
final class RecipeRepository: RecipeRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetch(by id: PersistentIdentifier) -> RecipeEntity? {
        return modelContext.model(for: id) as? RecipeEntity
    }

    func search(name: String) -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchFavorites() -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchByCategory(_ category: String) -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Create & Delete

    func create(_ recipe: RecipeEntity) {
        modelContext.insert(recipe)
        save()
    }

    func delete(_ recipe: RecipeEntity) {
        modelContext.delete(recipe)
        save()
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("[RecipeRepository] Save error: \(error)")
        }
    }
}
