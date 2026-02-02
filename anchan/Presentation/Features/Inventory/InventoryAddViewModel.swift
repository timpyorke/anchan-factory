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

    // MARK: - UI State

    var isLoading = false
    var isSaving = false
    var isDeleting = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var repository: InventoryRepository?
    private var customUnitRepository: CustomUnitRepository?
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
        self.repository = InventoryRepository(modelContext: modelContext)
        self.customUnitRepository = CustomUnitRepository(modelContext: modelContext)
        loadCustomUnits()
        loadEditingItem()
    }

    // MARK: - Actions

    private func loadCustomUnits() {
        guard let customUnitRepository else { return }

        isLoading = true
        defer { isLoading = false }

        switch customUnitRepository.fetchAll() {
        case .success(let units):
            customUnits = units
        case .failure(let error):
            handleError(error)
        }
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
        guard let repository else { return }

        isSaving = true
        defer { isSaving = false }

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
            onComplete()
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

            switch repository.create(item) {
            case .success:
                onComplete()
            case .failure(let error):
                handleError(error)
            }
        }
    }

    func deleteItem(onComplete: () -> Void) {
        guard let item = editingItem, let repository else { return }

        isDeleting = true
        defer { isDeleting = false }

        switch repository.delete(item) {
        case .success:
            onComplete()
        case .failure(let error):
            handleError(error)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
