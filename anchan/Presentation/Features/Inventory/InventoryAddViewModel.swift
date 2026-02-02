import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class InventoryAddViewModel {

    // MARK: - State Properties

    var name: String = ""
    var category: String = ""
    var unitSymbol: String = "g"
    var unitPrice: String = ""
    var stock: String = ""
    var minStock: String = ""
    private(set) var customUnits: [CustomUnitEntity] = []

    // MARK: - Dependencies

    private var repository: InventoryRepository?
    private var modelContext: ModelContext?
    private let editingItem: InventoryEntity?

    // MARK: - Computed Properties

    var isEditing: Bool { editingItem != nil }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var displaySymbol: String {
        unitSymbol.uppercased()
    }

    // MARK: - Init

    init(editingItem: InventoryEntity? = nil) {
        self.editingItem = editingItem
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.repository = InventoryRepository(modelContext: modelContext)
        loadCustomUnits()
        loadEditingItem()
    }

    // MARK: - Actions

    private func loadCustomUnits() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CustomUnitEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        customUnits = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func loadEditingItem() {
        guard let item = editingItem else { return }
        name = item.name
        category = item.category ?? ""
        unitSymbol = item.unitSymbol
        unitPrice = item.unitPrice > 0 ? String(item.unitPrice) : ""
        stock = item.stock > 0 ? String(item.stock) : ""
        minStock = item.minStock > 0 ? String(item.minStock) : ""
    }

    func saveItem(onComplete: () -> Void) {
        guard let modelContext else { return }

        let price = Double(unitPrice) ?? 0
        let stockValue = Double(stock) ?? 0
        let minStockValue = Double(minStock) ?? 0

        if let item = editingItem {
            // Update existing
            item.name = name.trimmingCharacters(in: .whitespaces)
            item.category = category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)
            item.unitSymbol = unitSymbol
            item.unitPrice = price
            item.stock = stockValue
            item.minStock = minStockValue
        } else {
            // Create new
            let item = InventoryEntity(
                name: name.trimmingCharacters(in: .whitespaces),
                unitSymbol: unitSymbol,
                unitPrice: price,
                stock: stockValue,
                minStock: minStockValue
            )
            if !category.isEmpty {
                item.category = category.trimmingCharacters(in: .whitespaces)
            }
            modelContext.insert(item)
        }

        onComplete()
    }

    func deleteItem(onComplete: () -> Void) {
        guard let item = editingItem else { return }
        repository?.delete(item)
        onComplete()
    }
}
