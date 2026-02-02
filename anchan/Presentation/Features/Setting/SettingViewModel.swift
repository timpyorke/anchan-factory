import SwiftUI
import SwiftData

@Observable
final class SettingViewModel {
    private var modelContext: ModelContext?
    private let exportService = CSVExportService.shared

    var showExportSheet = false
    var exportURL: URL?
    var showClearDataAlert = false
    var showAddUnitSheet = false
    var showRestartAlert = false

    var settings: AppSettings {
        AppSettings.shared
    }

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Delete Units

    func deleteUnits(at offsets: IndexSet, from units: [CustomUnitEntity]) {
        guard let modelContext else { return }
        for index in offsets {
            modelContext.delete(units[index])
        }
    }

    // MARK: - Clear All Data

    func clearAllData() {
        guard let modelContext else { return }

        // Delete all manufacturing
        let manufacturingDescriptor = FetchDescriptor<ManufacturingEntity>()
        if let items = try? modelContext.fetch(manufacturingDescriptor) {
            items.forEach { modelContext.delete($0) }
        }

        // Delete all recipes (cascades to ingredients and steps)
        let recipeDescriptor = FetchDescriptor<RecipeEntity>()
        if let items = try? modelContext.fetch(recipeDescriptor) {
            items.forEach { modelContext.delete($0) }
        }

        // Delete all inventory
        let inventoryDescriptor = FetchDescriptor<InventoryEntity>()
        if let items = try? modelContext.fetch(inventoryDescriptor) {
            items.forEach { modelContext.delete($0) }
        }

        // Delete custom units
        let unitDescriptor = FetchDescriptor<CustomUnitEntity>()
        if let items = try? modelContext.fetch(unitDescriptor) {
            items.forEach { modelContext.delete($0) }
        }
    }

    // MARK: - Export Manufacturing

    func exportManufacturingData() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<ManufacturingEntity>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        guard let items = try? modelContext.fetch(descriptor) else { return }

        exportURL = exportService.exportAllManufacturing(items)
        if exportURL != nil {
            showExportSheet = true
        }
    }

    // MARK: - Export Inventory

    func exportInventoryData() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<InventoryEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let items = try? modelContext.fetch(descriptor) else { return }

        exportURL = exportService.exportInventory(items)
        if exportURL != nil {
            showExportSheet = true
        }
    }

    // MARK: - Export Recipe

    func exportRecipeData() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let items = try? modelContext.fetch(descriptor) else { return }

        exportURL = exportService.exportRecipes(items)
        if exportURL != nil {
            showExportSheet = true
        }
    }
}
