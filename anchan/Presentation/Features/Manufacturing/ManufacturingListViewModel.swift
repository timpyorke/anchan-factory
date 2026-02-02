import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class ManufacturingListViewModel {

    // MARK: - State

    private(set) var allManufacturing: [ManufacturingEntity] = []

    // MARK: - UI State

    var searchText: String = ""
    var selectedFilter: ManufacturingFilter = .all
    var isLoading = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    private var repository: ManufacturingRepository?

    // MARK: - Computed Properties

    var filteredManufacturing: [ManufacturingEntity] {
        var result = allManufacturing

        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .active:
            result = result.filter { $0.status == .inProgress }
        case .completed:
            result = result.filter { $0.status == .completed }
        case .cancelled:
            result = result.filter { $0.status == .cancelled }
        }

        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { manufacturing in
                manufacturing.recipe.name.localizedCaseInsensitiveContains(searchText) ||
                manufacturing.batchNumber.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var activeCount: Int {
        allManufacturing.filter { $0.status == .inProgress }.count
    }

    var completedCount: Int {
        allManufacturing.filter { $0.status == .completed }.count
    }

    var cancelledCount: Int {
        allManufacturing.filter { $0.status == .cancelled }.count
    }

    // MARK: - Setup

    func setup(modelContext: ModelContext) {
        self.repository = ManufacturingRepository(modelContext: modelContext)
        loadData()
    }

    // MARK: - Actions

    func loadData() {
        guard let repository else { return }

        isLoading = true
        defer { isLoading = false }

        switch repository.fetchAll() {
        case .success(let items):
            // Sort by date (newest first)
            allManufacturing = items.sorted { $0.startedAt > $1.startedAt }
        case .failure(let error):
            handleError(error)
        }
    }

    func deleteManufacturing(_ manufacturing: ManufacturingEntity) {
        guard let repository else { return }

        switch repository.delete(manufacturing) {
        case .success:
            loadData()
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

// MARK: - Filter Enum

enum ManufacturingFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case completed
    case cancelled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return String(localized: "All")
        case .active:
            return String(localized: "Active")
        case .completed:
            return String(localized: "Completed")
        case .cancelled:
            return String(localized: "Cancelled")
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .active:
            return "play.circle"
        case .completed:
            return "checkmark.circle"
        case .cancelled:
            return "xmark.circle"
        }
    }
}
