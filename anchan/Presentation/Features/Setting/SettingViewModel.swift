import SwiftUI
import SwiftData

@Observable
final class SettingViewModel {
    private var customUnitRepository: CustomUnitRepository?
    private var manufacturingRepository: ManufacturingRepository?
    private var recipeRepository: RecipeRepository?
    private var inventoryRepository: InventoryRepository?
    private let exportService = CSVExportService.shared

    var showExportSheet = false
    var exportURL: URL?
    var showClearDataAlert = false
    var showAddUnitSheet = false
    var showRestartAlert = false
    var isLoading = false
    var isDeleting = false
    var errorMessage: String?
    var showError = false

    var settings: AppSettings {
        AppSettings.shared
    }

    func setup(modelContext: ModelContext) {
        self.customUnitRepository = CustomUnitRepository(modelContext: modelContext)
        self.manufacturingRepository = ManufacturingRepository(modelContext: modelContext)
        self.recipeRepository = RecipeRepository(modelContext: modelContext)
        self.inventoryRepository = InventoryRepository(modelContext: modelContext)
    }

    // MARK: - Delete Units

    func deleteUnits(at offsets: IndexSet, from units: [CustomUnitEntity]) {
        guard let customUnitRepository else { return }

        isDeleting = true
        defer { isDeleting = false }

        for index in offsets {
            switch customUnitRepository.delete(units[index]) {
            case .success:
                break
            case .failure(let error):
                handleError(error)
                return
            }
        }
    }

    // MARK: - Clear All Data

    func clearAllData() {
        guard let manufacturingRepository,
              let recipeRepository,
              let inventoryRepository,
              let customUnitRepository else { return }

        isDeleting = true
        defer { isDeleting = false }

        // Delete all manufacturing
        switch manufacturingRepository.fetchAll() {
        case .success(let items):
            for item in items {
                if case .failure(let error) = manufacturingRepository.delete(item) {
                    handleError(error)
                    return
                }
            }
        case .failure(let error):
            handleError(error)
            return
        }

        // Delete all recipes (cascades to ingredients and steps)
        switch recipeRepository.fetchAll() {
        case .success(let items):
            for item in items {
                if case .failure(let error) = recipeRepository.delete(item) {
                    handleError(error)
                    return
                }
            }
        case .failure(let error):
            handleError(error)
            return
        }

        // Delete all inventory
        switch inventoryRepository.fetchAll() {
        case .success(let items):
            for item in items {
                if case .failure(let error) = inventoryRepository.delete(item) {
                    handleError(error)
                    return
                }
            }
        case .failure(let error):
            handleError(error)
            return
        }

        // Delete custom units
        switch customUnitRepository.fetchAll() {
        case .success(let items):
            for item in items {
                if case .failure(let error) = customUnitRepository.delete(item) {
                    handleError(error)
                    return
                }
            }
        case .failure(let error):
            handleError(error)
        }
    }

    // MARK: - Export Manufacturing

    func exportManufacturingData() {
        guard let manufacturingRepository else { return }

        isLoading = true
        defer { isLoading = false }

        switch manufacturingRepository.fetchAll() {
        case .success(let items):
            exportURL = exportService.exportAllManufacturing(items)
            if exportURL != nil {
                showExportSheet = true
            }
        case .failure(let error):
            handleError(error)
        }
    }

    // MARK: - Export Inventory

    func exportInventoryData() {
        guard let inventoryRepository else { return }

        isLoading = true
        defer { isLoading = false }

        switch inventoryRepository.fetchAll() {
        case .success(let items):
            exportURL = exportService.exportInventory(items)
            if exportURL != nil {
                showExportSheet = true
            }
        case .failure(let error):
            handleError(error)
        }
    }

    // MARK: - Export Recipe

    func exportRecipeData() {
        guard let recipeRepository else { return }

        isLoading = true
        defer { isLoading = false }

        switch recipeRepository.fetchAll() {
        case .success(let items):
            exportURL = exportService.exportRecipes(items)
            if exportURL != nil {
                showExportSheet = true
            }
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
