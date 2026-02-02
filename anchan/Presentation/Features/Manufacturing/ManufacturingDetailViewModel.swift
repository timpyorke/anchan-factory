import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class ManufacturingDetailViewModel {

    // MARK: - State

    private(set) var manufacturing: ManufacturingEntity?

    // MARK: - UI State

    var showDeleteAlert = false
    var showShareSheet = false
    var exportURL: URL?

    // MARK: - Dependencies

    private var repository: ManufacturingRepository?
    private let exportService = CSVExportService.shared

    // MARK: - Setup

    func setup(modelContext: ModelContext, id: PersistentIdentifier) {
        self.repository = ManufacturingRepository(modelContext: modelContext)
        loadManufacturing(id: id)
    }

    // MARK: - Actions

    func loadManufacturing(id: PersistentIdentifier) {
        manufacturing = repository?.fetch(by: id)
    }

    func deleteManufacturing(onComplete: () -> Void) {
        guard let manufacturing else { return }
        repository?.delete(manufacturing)
        onComplete()
    }

    func exportToCSV() {
        guard let manufacturing else { return }
        exportURL = exportService.exportManufacturing(manufacturing)
        if exportURL != nil {
            showShareSheet = true
        }
    }

    // MARK: - Helpers

    func formatDuration(_ interval: TimeInterval) -> String {
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
}
