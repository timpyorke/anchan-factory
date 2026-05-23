import SwiftData
import Foundation

enum AppModelContainer {

    static func make() -> ModelContainer {
        let schema = Schema([
            RecipeEntity.self,
            RecipeStepEntity.self,
            InventoryEntity.self,
            IngredientEntity.self,
            ManufacturingEntity.self,
            ManufacturingImageEntity.self,
            ManufacturingStepLogEntity.self,
            CustomUnitEntity.self,
            MeasurementLogEntity.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        // Try to open the on-disk store. If migration or load fails (which
        // would otherwise terminate the app on launch), recover by moving the
        // corrupt store aside and reopening fresh. This is the best the user
        // can get without losing the app entirely; backup/restore lets them
        // get data back if they've used the Google Drive backup feature.
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            NSLog("[AppModelContainer] ❌ Initial open failed: \(error). Quarantining store and retrying.")
            quarantineExistingStore()
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                NSLog("[AppModelContainer] ❌ Second open failed: \(error). Falling back to in-memory store.")
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                // If even the in-memory store can't be created, there is nothing
                // we can do — but this should be effectively unreachable.
                return (try? ModelContainer(for: schema, configurations: [memoryConfig]))
                    ?? (try! ModelContainer(for: schema))
            }
        }
    }

    /// Move any existing SwiftData store files out of the way so a fresh container can open.
    private static func quarantineExistingStore() {
        let fm = FileManager.default
        guard let appSupport = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }

        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let quarantineRoot = appSupport.appendingPathComponent("CorruptStores", isDirectory: true)
        try? fm.createDirectory(at: quarantineRoot, withIntermediateDirectories: true)
        let quarantineDir = quarantineRoot.appendingPathComponent(timestamp, isDirectory: true)
        try? fm.createDirectory(at: quarantineDir, withIntermediateDirectories: true)

        let candidates = ["default.store", "default.store-shm", "default.store-wal"]
        for name in candidates {
            let src = appSupport.appendingPathComponent(name)
            if fm.fileExists(atPath: src.path) {
                let dst = quarantineDir.appendingPathComponent(name)
                try? fm.moveItem(at: src, to: dst)
            }
        }
    }
}
