import SwiftData
import Foundation

@MainActor
protocol ManufacturingRepositoryProtocol {
    func fetchAll() -> Result<[ManufacturingEntity], AppError>
    func fetchActive() -> Result<[ManufacturingEntity], AppError>
    func fetchCompleted() -> Result<[ManufacturingEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<ManufacturingEntity, AppError>
    func create(_ manufacturing: ManufacturingEntity) -> Result<Void, AppError>
    func update() -> Result<Void, AppError>
    func delete(_ manufacturing: ManufacturingEntity) -> Result<Void, AppError>
}

@MainActor
final class ManufacturingRepository: ManufacturingRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() -> Result<[ManufacturingEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<ManufacturingEntity>(
                sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
            )
            let items = try modelContext.fetch(descriptor)
            return .success(items)
        } catch {
            return .failure(.databaseError("Failed to fetch manufacturing records"))
        }
    }

    func fetchActive() -> Result<[ManufacturingEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<ManufacturingEntity>(
                sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
            )
            let allItems = try modelContext.fetch(descriptor)
            let items = allItems.filter { $0.status == .inProgress }
            return .success(items)
        } catch {
            return .failure(.databaseError("Failed to fetch active manufacturing records"))
        }
    }

    func fetchCompleted() -> Result<[ManufacturingEntity], AppError> {
        do {
            let descriptor = FetchDescriptor<ManufacturingEntity>(
                sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
            )
            let allItems = try modelContext.fetch(descriptor)
            let items = allItems.filter { $0.status == .completed }
            // Sort completed by completedAt
            let sorted = items.sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
            return .success(sorted)
        } catch {
            return .failure(.databaseError("Failed to fetch completed manufacturing records"))
        }
    }

    func fetch(by id: PersistentIdentifier) -> Result<ManufacturingEntity, AppError> {
        guard let item = modelContext.model(for: id) as? ManufacturingEntity else {
            return .failure(.notFound("Manufacturing record"))
        }
        return .success(item)
    }

    // MARK: - Create, Update & Delete

    func create(_ manufacturing: ManufacturingEntity) -> Result<Void, AppError> {
        modelContext.insert(manufacturing)
        return save()
    }

    func update() -> Result<Void, AppError> {
        return save()
    }

    func delete(_ manufacturing: ManufacturingEntity) -> Result<Void, AppError> {
        modelContext.delete(manufacturing)
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
