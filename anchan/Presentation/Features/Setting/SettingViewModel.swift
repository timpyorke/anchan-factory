import SwiftUI
import SwiftData

@Observable
final class SettingViewModel {
    private var modelContext: ModelContext?

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
        guard let items = try? modelContext.fetch(descriptor), !items.isEmpty else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var csv = "Batch Number,Recipe,Category,Status,Started,Completed,Duration,Batches,Batch Size,Total Units,Total Cost,Cost Per Unit\n"

        for m in items {
            let status = m.status.rawValue.capitalized
            let started = dateFormatter.string(from: m.startedAt)
            let completed = m.completedAt.map { dateFormatter.string(from: $0) } ?? "-"
            let duration = m.isCompleted ? formatDuration(m.totalDuration) : "-"
            let category = m.recipe.category ?? "-"

            csv += "\(m.batchNumber),"
            csv += "\"\(m.recipe.name.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\"\(category.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\(status),\(started),\(completed),\(duration),"
            csv += "\(m.quantity),\(m.recipe.batchSize) \(m.recipe.batchUnit),"
            csv += "\(m.totalUnits),฿\(String(format: "%.2f", m.totalCost)),"
            csv += "฿\(String(format: "%.2f", m.costPerUnit))\n"
        }

        saveAndShare(csv: csv, fileName: "Manufacturing_Report")
    }

    // MARK: - Export Inventory

    func exportInventoryData() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<InventoryEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let items = try? modelContext.fetch(descriptor), !items.isEmpty else { return }

        var csv = "Name,Category,Unit,Stock,Min Stock,Unit Price,Status\n"

        for item in items {
            let category = item.category ?? "-"
            let status = item.isLowStock ? "Low Stock" : "OK"

            csv += "\"\(item.name.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\"\(category.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\(item.displaySymbol),"
            csv += "\(String(format: "%.2f", item.stock)),"
            csv += "\(String(format: "%.2f", item.minStock)),"
            csv += "฿\(String(format: "%.2f", item.unitPrice)),"
            csv += "\(status)\n"
        }

        saveAndShare(csv: csv, fileName: "Inventory_Report")
    }

    // MARK: - Export Recipe

    func exportRecipeData() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let items = try? modelContext.fetch(descriptor), !items.isEmpty else { return }

        var csv = "Name,Category,Batch Size,Batch Unit,Total Cost,Cost Per Unit,Steps,Ingredients\n"

        for recipe in items {
            let category = recipe.category ?? "-"
            let ingredientNames = recipe.ingredients.map { $0.inventoryItem.name }.joined(separator: "; ")

            csv += "\"\(recipe.name.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\"\(category.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\(recipe.batchSize),"
            csv += "\(recipe.batchUnit),"
            csv += "฿\(String(format: "%.2f", recipe.totalCost)),"
            csv += "฿\(String(format: "%.2f", recipe.costPerUnit)),"
            csv += "\(recipe.steps.count),"
            csv += "\"\(ingredientNames.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
        }

        saveAndShare(csv: csv, fileName: "Recipe_Report")
    }

    // MARK: - Helpers

    private func saveAndShare(csv: String, fileName: String) {
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "yyyyMMdd_HHmmss"

        let fullFileName = "\(fileName)_\(shortDateFormatter.string(from: Date.now)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fullFileName)

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            exportURL = tempURL
            showExportSheet = true
        } catch {
            print("Failed to export: \(error)")
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
