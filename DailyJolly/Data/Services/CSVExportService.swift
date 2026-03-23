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
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter
    }()

    // MARK: - Manufacturing Export

    /// Export detailed manufacturing record including steps and measurements
    func exportManufacturingDetail(_ manufacturing: ManufacturingEntity) -> URL? {
        var csv = "MANUFACTURING RECORD\n"
        csv += CSVEngine.shared.formatRow(["Batch Number", manufacturing.batchNumber]) + "\n"
        csv += CSVEngine.shared.formatRow(["Recipe", manufacturing.recipe.name]) + "\n"
        csv += CSVEngine.shared.formatRow(["Category", manufacturing.recipe.category ?? "-"]) + "\n"
        csv += CSVEngine.shared.formatRow(["Status", manufacturing.status.rawValue.capitalized]) + "\n"
        csv += CSVEngine.shared.formatRow(["Started", dateFormatter.string(from: manufacturing.startedAt)]) + "\n"
        
        if let completedAt = manufacturing.completedAt {
            csv += CSVEngine.shared.formatRow(["Completed", dateFormatter.string(from: completedAt)]) + "\n"
            csv += CSVEngine.shared.formatRow(["Total Duration", TimeFormatter.formatDuration(manufacturing.totalDuration)]) + "\n"
        }
        
        csv += CSVEngine.shared.formatRow(["Batches", "\(manufacturing.quantity)"]) + "\n"
        csv += CSVEngine.shared.formatRow(["Total Units", "\(manufacturing.totalUnits) \(manufacturing.recipe.batchUnit)"]) + "\n"
        csv += CSVEngine.shared.formatRow(["Actual Output", "\(manufacturing.actualOutput ?? Double(manufacturing.totalUnits))"]) + "\n"
        csv += CSVEngine.shared.formatRow(["Total Cost", String(format: "%.2f", manufacturing.totalCost)]) + "\n"
        csv += "\n"

        // Steps Section
        if !manufacturing.recipe.steps.isEmpty {
            csv += "STEPS\n"
            csv += CSVEngine.shared.formatRow(["Step", "Title", "Actual Time", "Completed At"]) + "\n"
            for (index, step) in manufacturing.recipe.sortedSteps.enumerated() {
                let isCompleted = manufacturing.isStepCompleted(at: index)
                let actualTime = isCompleted
                    ? TimeFormatter.formatDuration(manufacturing.stepDuration(at: index))
                    : "-"
                let completedAt = manufacturing.stepCompletionTime(at: index)
                    .map { dateFormatter.string(from: $0) } ?? "-"

                let row = [
                    "\(index + 1)",
                    step.title,
                    actualTime,
                    completedAt
                ]
                csv += CSVEngine.shared.formatRow(row) + "\n"
            }
            csv += "\n"
        }

        // Quality Control Measurements Section
        let measurements = manufacturing.measurements
        if !measurements.isEmpty {
            csv += "QUALITY CONTROL MEASUREMENTS\n"
            csv += CSVEngine.shared.formatRow(["Step", "Measurement", "Value", "Unit", "Timestamp"]) + "\n"
            let sortedSteps = manufacturing.recipe.sortedSteps
            for log in measurements.sorted(by: { $0.timestamp < $1.timestamp }) {
                let stepTitle = log.stepIndex < sortedSteps.count ? sortedSteps[log.stepIndex].title : "Unknown"
                let row = [
                    stepTitle,
                    log.type.rawValue,
                    String(format: "%.2f", log.value),
                    log.type.symbol,
                    dateFormatter.string(from: log.timestamp)
                ]
                csv += CSVEngine.shared.formatRow(row) + "\n"
            }
        }

        let fileName = "Manufacturing_\(manufacturing.batchNumber)"
        return saveCSV(csv, fileName: fileName)
    }

    /// Export all manufacturing records in list format
    func exportAllManufacturing(_ items: [ManufacturingEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        let headers = ["Batch Number", "Recipe", "Category", "Status", "Started", "Completed", "Duration", "Batches", "Batch Size", "Total Units", "Actual Units", "Total Cost", "Cost Per Unit"]
        var csv = CSVEngine.shared.formatRow(headers) + "\n"

        for m in items {
            let status = m.status.rawValue.capitalized
            let started = dateFormatter.string(from: m.startedAt)
            let completed = m.completedAt.map { dateFormatter.string(from: $0) } ?? "-"
            let duration = m.isCompleted ? TimeFormatter.formatDuration(m.totalDuration) : "-"
            let category = m.recipe.category ?? "-"
            let actualUnits = m.actualOutput.map { String(format: "%.2f", $0) } ?? String(m.totalUnits)

            let row = [
                m.batchNumber,
                m.recipe.name,
                category,
                status,
                started,
                completed,
                duration,
                "\(m.quantity)",
                "\(m.recipe.batchSize) \(m.recipe.batchUnit)",
                "\(m.totalUnits)",
                actualUnits,
                String(format: "%.2f", m.totalCost),
                String(format: "%.2f", m.costPerUnit)
            ]
            csv += CSVEngine.shared.formatRow(row) + "\n"
        }

        return saveCSV(csv, fileName: "Manufacturing_Report")
    }

    // MARK: - Inventory Export

    func exportInventory(_ items: [InventoryEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        let headers = ["Name", "Category", "Unit", "Stock", "Min Stock", "pH", "Unit Price", "Status"]
        var csv = CSVEngine.shared.formatRow(headers) + "\n"

        for item in items {
            let category = item.category ?? "-"
            let status = item.isLowStock ? "Low Stock" : "OK"
            let phValue = item.phValue.map { String(format: "%.2f", $0) } ?? "-"

            let row = [
                item.name,
                category,
                item.displaySymbol,
                String(format: "%.2f", item.stock),
                String(format: "%.2f", item.minStock),
                phValue,
                String(format: "%.2f", item.unitPrice),
                status
            ]
            csv += CSVEngine.shared.formatRow(row) + "\n"
        }

        return saveCSV(csv, fileName: "Inventory_Report")
    }

    // MARK: - Recipe Export

    func exportRecipes(_ items: [RecipeEntity]) -> URL? {
        guard !items.isEmpty else { return nil }

        let headers = ["Name", "Category", "Batch Size", "Batch Unit", "Total Cost", "Cost Per Unit", "Steps", "Ingredients", "Required QC"]
        var csv = CSVEngine.shared.formatRow(headers) + "\n"

        for recipe in items {
            let category = recipe.category ?? "-"
            let ingredientNames = recipe.ingredients.map { $0.inventoryItem.name }.joined(separator: "; ")
            let qcTypes = Set(recipe.steps.flatMap { $0.requiredMeasurements }).map { $0.rawValue }.joined(separator: "; ")

            let row = [
                recipe.name,
                category,
                "\(recipe.batchSize)",
                recipe.batchUnit,
                String(format: "%.2f", recipe.totalCost),
                String(format: "%.2f", recipe.costPerUnit),
                "\(recipe.steps.count)",
                ingredientNames,
                qcTypes
            ]
            csv += CSVEngine.shared.formatRow(row) + "\n"
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
}
