import SwiftData
import Foundation

@MainActor
protocol CustomUnitRepositoryProtocol {
    func fetchAll() -> Result<[CustomUnitEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<CustomUnitEntity, AppError>
    func fetchBySymbol(_ symbol: String) -> Result<CustomUnitEntity?, AppError>
    func create(_ unit: CustomUnitEntity) -> Result<Void, AppError>
    func delete(_ unit: CustomUnitEntity) -> Result<Void, AppError>
}

@MainActor
final class CustomUnitRepository: CustomUnitRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() -> Result<[CustomUnitEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<CustomUnitEntity>(
                sortBy: [SortDescriptor(\.name)]
            )
            let units = try modelContext.fetch(descriptor)
            return .success(units)
        } catch {
            return .failure(.databaseError("Failed to fetch custom units"))
        }
    }

    func fetch(by id: PersistentIdentifier) -> Result<CustomUnitEntity, AppError> {
        guard let unit = modelContext.model(for: id) as? CustomUnitEntity else {
            return .failure(.notFound("Custom unit"))
        }
        return .success(unit)
    }

    func fetchBySymbol(_ symbol: String) -> Result<CustomUnitEntity?, AppError> {
        do {
            let lowercasedSymbol = symbol.lowercased()
            let descriptor = FetchDescriptor<CustomUnitEntity>(
                predicate: #Predicate { $0.symbol == lowercasedSymbol }
            )
            let units = try modelContext.fetch(descriptor)
            return .success(units.first)
        } catch {
            return .failure(.databaseError("Failed to fetch custom unit by symbol"))
        }
    }

    // MARK: - Create & Delete

    func create(_ unit: CustomUnitEntity) -> Result<Void, AppError> {
        modelContext.insert(unit)
        return save()
    }

    func delete(_ unit: CustomUnitEntity) -> Result<Void, AppError> {
        modelContext.delete(unit)
        return save()
    }

    // MARK: - Private

    private func save() -> Result<Void, AppError> {
        do {
            try modelContext.save()
            return .success(())
        } catch {
            return .failure(.databaseError("Failed to save changes: \(error.localizedDescription)"))
        }
    }
}
