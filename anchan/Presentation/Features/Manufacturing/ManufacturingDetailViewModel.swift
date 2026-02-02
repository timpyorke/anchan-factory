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
    var isLoading = false
    var isDeleting = false
    var errorMessage: String?
    var showError = false

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
        guard let repository else { return }

        isLoading = true
        defer { isLoading = false }

        switch repository.fetch(by: id) {
        case .success(let item):
            manufacturing = item
        case .failure(let error):
            handleError(error)
        }
    }

    func deleteManufacturing(onComplete: () -> Void) {
        guard let manufacturing, let repository else { return }

        isDeleting = true
        defer { isDeleting = false }

        switch repository.delete(manufacturing) {
        case .success:
            onComplete()
        case .failure(let error):
            handleError(error)
        }
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
        return TimeFormatter.formatDuration(interval)
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
