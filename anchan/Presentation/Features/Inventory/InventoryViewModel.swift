import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class InventoryViewModel {

    // MARK: - State

    private(set) var items: [InventoryEntity] = []
    var searchText: String = ""
    var isShowingAddSheet: Bool = false
    var editingItem: InventoryEntity?

    // MARK: - UI State

    var isLoading = false
    var isDeleting = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var repository: InventoryRepository?

    // MARK: - Computed

    var filteredItems: [InventoryEntity] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var isShowingEditSheet: Bool {
        get { editingItem != nil }
        set { if !newValue { editingItem = nil } }
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.repository = InventoryRepository(modelContext: modelContext)
        loadItems()
    }

    // MARK: - Actions

    func loadItems() {
        guard let repository else { return }

        isLoading = true
        defer { isLoading = false }

        switch repository.fetchAll() {
        case .success(let fetchedItems):
            items = fetchedItems
        case .failure(let error):
            handleError(error)
        }
    }

    func edit(_ item: InventoryEntity) {
        editingItem = item
    }

    func deleteItems(at offsets: IndexSet) {
        guard let repository else { return }

        isDeleting = true
        defer { isDeleting = false }

        for index in offsets {
            let item = filteredItems[index]
            switch repository.delete(item) {
            case .success:
                break
            case .failure(let error):
                handleError(error)
                return
            }
        }
        loadItems()
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
