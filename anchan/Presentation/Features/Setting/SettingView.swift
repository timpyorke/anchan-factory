import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingViewModel()
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    var body: some View {
        Form {
            Section {
                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            }

            Section {
                Button {
                    exportManufacturingData()
                } label: {
                    Label("Export Manufacturing Data", systemImage: "tablecells")
                }
            } header: {
                Text("Export")
            } footer: {
                Text("Export all manufacturing records as CSV for Google Sheets")
            }
        }
        .navigationTitle("Setting")
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportManufacturingData() {
        let descriptor = FetchDescriptor<ManufacturingEntity>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        guard let allManufacturing = try? modelContext.fetch(descriptor) else { return }

        if allManufacturing.isEmpty {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "yyyyMMdd_HHmmss"

        // CSV Header
        var csv = "Batch Number,Recipe,Category,Status,Started,Completed,Duration,Batches,Batch Size,Total Units,Total Cost,Cost Per Unit\n"

        // Add each manufacturing record
        for m in allManufacturing {
            let status = m.status.rawValue.capitalized
            let started = dateFormatter.string(from: m.startedAt)
            let completed = m.completedAt.map { dateFormatter.string(from: $0) } ?? "-"
            let duration = m.isCompleted ? formatDuration(m.totalDuration) : "-"
            let category = m.recipe.category ?? "-"

            csv += "\(m.batchNumber),"
            csv += "\"\(m.recipe.name.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\"\(category.replacingOccurrences(of: "\"", with: "\"\""))\","
            csv += "\(status),"
            csv += "\(started),"
            csv += "\(completed),"
            csv += "\(duration),"
            csv += "\(m.quantity),"
            csv += "\(m.recipe.batchSize) \(m.recipe.batchUnit),"
            csv += "\(m.totalUnits),"
            csv += "฿\(String(format: "%.2f", m.totalCost)),"
            csv += "฿\(String(format: "%.2f", m.costPerUnit))\n"
        }

        // Summary section
        let completedCount = allManufacturing.filter { $0.status == .completed }.count
        let inProgressCount = allManufacturing.filter { $0.status == .inProgress }.count
        let totalCost = allManufacturing.reduce(0.0) { $0 + $1.totalCost }
        let totalUnits = allManufacturing.reduce(0) { $0 + $1.totalUnits }

        csv += "\n"
        csv += "SUMMARY\n"
        csv += "Total Records,\(allManufacturing.count)\n"
        csv += "Completed,\(completedCount)\n"
        csv += "In Progress,\(inProgressCount)\n"
        csv += "Total Units Produced,\(totalUnits)\n"
        csv += "Total Cost,฿\(String(format: "%.2f", totalCost))\n"

        // Save to file
        let fileName = "Manufacturing_Report_\(shortDateFormatter.string(from: Date.now)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

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
