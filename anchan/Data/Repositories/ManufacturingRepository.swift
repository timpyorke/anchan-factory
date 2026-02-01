import SwiftData
import Foundation

protocol ManufacturingRepositoryProtocol {
    func fetchAll() -> [ManufacturingEntity]
    func fetchActive() -> [ManufacturingEntity]
    func fetchCompleted() -> [ManufacturingEntity]
    func fetch(by id: PersistentIdentifier) -> ManufacturingEntity?
    func create(_ manufacturing: ManufacturingEntity)
    func delete(_ manufacturing: ManufacturingEntity)
}

@MainActor
final class ManufacturingRepository: ManufacturingRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetchAll() -> [ManufacturingEntity] {
        let descriptor = FetchDescriptor<ManufacturingEntity>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchActive() -> [ManufacturingEntity] {
        let inProgressStatus = ManufacturingStatus.inProgress
        let descriptor = FetchDescriptor<ManufacturingEntity>(
            predicate: #Predicate { $0.status == inProgressStatus },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchCompleted() -> [ManufacturingEntity] {
        let completedStatus = ManufacturingStatus.completed
        let descriptor = FetchDescriptor<ManufacturingEntity>(
            predicate: #Predicate { $0.status == completedStatus },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetch(by id: PersistentIdentifier) -> ManufacturingEntity? {
        return modelContext.model(for: id) as? ManufacturingEntity
    }

    // MARK: - Create & Delete

    func create(_ manufacturing: ManufacturingEntity) {
        modelContext.insert(manufacturing)
        save()
    }

    func delete(_ manufacturing: ManufacturingEntity) {
        modelContext.delete(manufacturing)
        save()
    }

    // MARK: - Private

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("[ManufacturingRepository] Save error: \(error)")
        }
    }
}
