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
        items = repository?.fetchAll() ?? []
    }

    func edit(_ item: InventoryEntity) {
        editingItem = item
    }

    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            repository?.delete(item)
        }
        loadItems()
    }
}
