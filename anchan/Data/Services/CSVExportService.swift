import Foundation
import SwiftData

@MainActor
final class CSVExportService {

    static let shared = CSVExportService()

    private init() {}

    // MARK: - Date Formatters

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private lazy var fileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()

    // MARK: - Manufacturing Export

    /// Export a single manufacturing record with detailed sections
    func exportManufacturing(_ manufacturing: ManufacturingEntity) -> URL? {
        var csv = "Manufacturing Report\n"
        csv += "Generated:,\(dateFormatter.string(from: Date.now))\n\n"

        // Summary Section
        csv += "SUMMARY\n"
        csv += "Batch Number,\(manufacturing.batchNumber)\n"
        csv += "Recipe,\(manufacturing.recipe.name)\n"
        csv += "Status,\(manufacturing.status.rawValue.capitalized)\n"
        csv += "Started,\(dateFormatter.string(from: manufacturing.startedAt))\n"
        if let completedAt = manufacturing.completedAt {
            csv += "Completed,\(dateFormatter.string(from: completedAt))\n"
            csv += "Duration,\(formatDuration(manufacturing.totalDuration))\n"
        }
        csv += "\n"

        // Production Section
        csv += "PRODUCTION\n"
        csv += "Batches,\(manufacturing.quantity)\n"
        csv += "Batch Size,\(manufacturing.recipe.batchSize) \(manufacturing.recipe.batchUnit)\n"
        csv += "Total Units,\(manufacturing.totalUnits) \(manufacturing.recipe.batchUnit)\n"
        csv += "\n"

        // Cost Section
        csv += "COSTS\n"
        csv += "Total Cost,฿\(String(format: "%.2f", manufacturing.totalCost))\n"
        csv += "Cost per Unit,฿\(String(format: "%.2f", manufacturing.costPerUnit))\n"
        csv += "\n"

        // Ingredients Section
        if !manufacturing.recipe.ingredients.isEmpty {
            csv += "INGREDIENTS\n"
            csv += "Item,Quantity,Unit,Unit Price,Subtotal\n"
            for ingredient in manufacturing.recipe.ingredients {
                let subtotal = ingredient.quantityInBaseUnit * ingredient.inventoryItem.unitPrice
                csv += "\(ingredient.inventoryItem.name),"
                csv += "\(ingredient.quantity),"
                csv += "\(ingredient.displaySymbol),"
                csv += "฿\(String(format: "%.2f", ingredient.inventoryItem.unitPrice)),"
                csv += "฿\(String(format: "%.2f", subtotal))\n"
            }
            csv += "\n"
        }

        // Steps Section
        if !manufacturing.recipe.steps.isEmpty {
            csv += "STEPS\n"
            csv += "Step,Title,Est. Time,Actual Time,Completed At\n"
            for (index, step) in manufacturing.recipe.sortedSteps.enumerated() {
                let actualTime = index < manufacturing.stepCompletionTimes.count
                    ? formatDuration(manufacturing.stepDuration(at: index))
                    : "-"
                let completedAt = manufacturing.stepCompletionTime(at: index)
                    .map { dateFormatter.string(from: $0) } ?? "-"

                csv += "\(index + 1),"
                csv += "\"\(escapeCSV(step.title))\","
                csv += "\(TimeFormatter.formatSeconds(step.time)),"
                csv += "\(actualTime),"
                csv += "\(completedAt)\n"
            }
        }

        let fileName = "Manufacturing_\(manufacturing.batchNumber).csv"
        return saveCSV(csv, fileName: fileName)
    }

    /// Export all manufacturing records in list format
    func exportAllManufacturing(_ items: [ManufacturingEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        var csv = "Batch Number,Recipe,Category,Status,Started,Completed,Duration,Batches,Batch Size,Total Units,Total Cost,Cost Per Unit\n"

        for m in items {
            let status = m.status.rawValue.capitalized
            let started = dateFormatter.string(from: m.startedAt)
            let completed = m.completedAt.map { dateFormatter.string(from: $0) } ?? "-"
            let duration = m.isCompleted ? formatDuration(m.totalDuration) : "-"
            let category = m.recipe.category ?? "-"

            csv += "\(m.batchNumber),"
            csv += "\"\(escapeCSV(m.recipe.name))\","
            csv += "\"\(escapeCSV(category))\","
            csv += "\(status),\(started),\(completed),\(duration),"
            csv += "\(m.quantity),\(m.recipe.batchSize) \(m.recipe.batchUnit),"
            csv += "\(m.totalUnits),฿\(String(format: "%.2f", m.totalCost)),"
            csv += "฿\(String(format: "%.2f", m.costPerUnit))\n"
        }

        return saveCSV(csv, fileName: "Manufacturing_Report")
    }

    // MARK: - Inventory Export

    func exportInventory(_ items: [InventoryEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        var csv = "Name,Category,Unit,Stock,Min Stock,Unit Price,Status\n"

        for item in items {
            let category = item.category ?? "-"
            let status = item.isLowStock ? "Low Stock" : "OK"

            csv += "\"\(escapeCSV(item.name))\","
            csv += "\"\(escapeCSV(category))\","
            csv += "\(item.displaySymbol),"
            csv += "\(String(format: "%.2f", item.stock)),"
            csv += "\(String(format: "%.2f", item.minStock)),"
            csv += "฿\(String(format: "%.2f", item.unitPrice)),"
            csv += "\(status)\n"
        }

        return saveCSV(csv, fileName: "Inventory_Report")
    }

    // MARK: - Recipe Export

    func exportRecipes(_ items: [RecipeEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        var csv = "Name,Category,Batch Size,Batch Unit,Total Cost,Cost Per Unit,Steps,Ingredients\n"

        for recipe in items {
            let category = recipe.category ?? "-"
            let ingredientNames = recipe.ingredients.map { $0.inventoryItem.name }.joined(separator: "; ")

            csv += "\"\(escapeCSV(recipe.name))\","
            csv += "\"\(escapeCSV(category))\","
            csv += "\(recipe.batchSize),"
            csv += "\(recipe.batchUnit),"
            csv += "฿\(String(format: "%.2f", recipe.totalCost)),"
            csv += "฿\(String(format: "%.2f", recipe.costPerUnit)),"
            csv += "\(recipe.steps.count),"
            csv += "\"\(escapeCSV(ingredientNames))\"\n"
        }

        return saveCSV(csv, fileName: "Recipe_Report")
    }

    // MARK: - Private Helpers

    private func saveCSV(_ content: String, fileName: String) -> URL? {
        let fullFileName = "\(fileName)_\(fileDateFormatter.string(from: Date.now)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fullFileName)

        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("[CSVExportService] Failed to save CSV: \(error)")
            return nil
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private func escapeCSV(_ text: String) -> String {
        text.replacingOccurrences(of: "\"", with: "\"\"")
    }
}
