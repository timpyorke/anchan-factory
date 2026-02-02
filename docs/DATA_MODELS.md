# Data Models

This document describes the data layer and models used in Anchan Factory.

## Overview

The app uses **SwiftData** for data persistence. All persistent models use the `@Model` macro with relationships managed via `@Relationship`.

## SwiftData Configuration

### AppModelContainer

Located in `Core/Database/AppModelContainer.swift`

```swift
@MainActor
let appModelContainer: ModelContainer = {
    let schema = Schema([
        RecipeEntity.self,
        RecipeStepEntity.self,
        IngredientEntity.self,
        InventoryEntity.self,
        ManufacturingEntity.self,
        CustomUnitEntity.self,
    ])
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )
    return try! ModelContainer(
        for: schema,
        configurations: [configuration]
    )
}()
```

**Key Points:**
- Uses `@MainActor` for thread safety
- Schema includes all model types
- Data is persisted to disk (`isStoredInMemoryOnly: false`)
- Cascade delete rules for relationships

## Entities

### RecipeEntity

Represents a recipe with ingredients and production steps.

**File:** `Data/Entity/RecipeEntity.swift`

```swift
@Model
final class RecipeEntity {
    var name: String
    var note: String
    var category: String?
    var isFavorite: Bool
    var batchSize: Int
    var batchUnit: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \IngredientEntity.recipe)
    var ingredients: [IngredientEntity]

    @Relationship(deleteRule: .cascade, inverse: \RecipeStepEntity.recipe)
    var steps: [RecipeStepEntity]

    init(name: String, note: String = "", batchSize: Int = 1, batchUnit: String = "pcs") {
        self.name = name
        self.note = note
        self.batchSize = batchSize
        self.batchUnit = batchUnit
        self.isFavorite = false
        self.createdAt = Date()
        self.ingredients = []
        self.steps = []
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Recipe name |
| `note` | String | Additional notes |
| `category` | String? | Recipe category |
| `isFavorite` | Bool | Favorited flag |
| `batchSize` | Int | Output quantity per batch |
| `batchUnit` | String | Output unit (e.g., "pcs", "bottles") |
| `createdAt` | Date | Creation timestamp |
| `ingredients` | [IngredientEntity] | Recipe ingredients |
| `steps` | [RecipeStepEntity] | Production steps |

**Computed Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `totalTime` | Int | Sum of all step times (minutes) |
| `totalCost` | Double | Sum of ingredient costs |
| `costPerUnit` | Double | Total cost / batch size |
| `hasEnoughInventory` | Bool | All ingredients have sufficient stock |
| `insufficientIngredients` | [IngredientEntity] | Ingredients with low stock |

### RecipeStepEntity

Represents a production step within a recipe.

**File:** `Data/Entity/RecipeStepEntity.swift`

```swift
@Model
final class RecipeStepEntity {
    var title: String
    var note: String
    var time: Int  // minutes
    var order: Int
    var recipe: RecipeEntity?

    init(title: String, note: String = "", time: Int = 0, order: Int = 0) {
        self.title = title
        self.note = note
        self.time = time
        self.order = order
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `title` | String | Step title |
| `note` | String | Step instructions/notes |
| `time` | Int | Estimated time in minutes |
| `order` | Int | Step sequence order |
| `recipe` | RecipeEntity? | Parent recipe (inverse) |

### IngredientEntity

Represents an ingredient used in a recipe, linked to inventory.

**File:** `Data/Entity/IngredientEntity.swift`

```swift
@Model
final class IngredientEntity {
    var quantity: Double
    var unitSymbol: String
    var note: String?
    var inventoryItem: InventoryEntity
    var recipe: RecipeEntity?

    init(quantity: Double, unitSymbol: String, inventoryItem: InventoryEntity) {
        self.quantity = quantity
        self.unitSymbol = unitSymbol
        self.inventoryItem = inventoryItem
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `quantity` | Double | Amount needed |
| `unitSymbol` | String | Unit (g, ml, pcs, or custom) |
| `note` | String? | Optional notes |
| `inventoryItem` | InventoryEntity | Linked inventory item |
| `recipe` | RecipeEntity? | Parent recipe (inverse) |

**Computed Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `displaySymbol` | String | Uppercase unit symbol |
| `quantityInBaseUnit` | Double | Converted to base unit |
| `hasEnoughStock` | Bool | Inventory has sufficient stock |
| `shortage` | Double | Amount lacking (if any) |

### InventoryEntity

Represents an inventory item with stock tracking.

**File:** `Data/Entity/InventoryEntity.swift`

```swift
@Model
final class InventoryEntity {
    var name: String
    var category: String?
    var unitSymbol: String
    var unitPrice: Double
    var stock: Double
    var minStock: Double
    var createdAt: Date

    init(name: String, unitSymbol: String = "pcs", unitPrice: Double = 0, stock: Double = 0, minStock: Double = 0) {
        self.name = name
        self.unitSymbol = unitSymbol
        self.unitPrice = unitPrice
        self.stock = stock
        self.minStock = minStock
        self.createdAt = Date()
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Item name |
| `category` | String? | Item category |
| `unitSymbol` | String | Measurement unit |
| `unitPrice` | Double | Price per unit |
| `stock` | Double | Current stock level |
| `minStock` | Double | Minimum stock threshold |
| `createdAt` | Date | Creation timestamp |

**Computed Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `builtInUnit` | InventoryUnit? | Built-in unit if applicable |
| `displaySymbol` | String | Uppercase unit symbol |
| `isLowStock` | Bool | Stock < minStock |
| `restockAmount` | Double | minStock - stock |
| `stockLevel` | Double | 0-1 percentage |

### ManufacturingEntity

Represents a manufacturing batch/production run.

**File:** `Data/Entity/ManufacturingEntity.swift`

```swift
@Model
final class ManufacturingEntity {
    var batchNumber: String
    var status: ManufacturingStatus
    var currentStepIndex: Int
    var quantity: Int
    var startedAt: Date
    var completedAt: Date?
    var stepCompletionTimes: [Date]
    var recipe: RecipeEntity

    init(recipe: RecipeEntity, quantity: Int = 1, batchNumber: String) {
        self.recipe = recipe
        self.quantity = quantity
        self.batchNumber = batchNumber
        self.status = .pending
        self.currentStepIndex = 0
        self.startedAt = Date()
        self.stepCompletionTimes = []
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `batchNumber` | String | Unique batch ID (YYMMDD-XXX) |
| `status` | ManufacturingStatus | Current status |
| `currentStepIndex` | Int | Active step index |
| `quantity` | Int | Number of batches |
| `startedAt` | Date | Start timestamp |
| `completedAt` | Date? | Completion timestamp |
| `stepCompletionTimes` | [Date] | Step completion timestamps |
| `stepNotes` | [String] | Notes for each completed step |
| `recipe` | RecipeEntity | Recipe being manufactured |

**ManufacturingStatus Enum:**

| Case | Description |
|------|-------------|
| `pending` | Not yet started |
| `inProgress` | Currently manufacturing |
| `completed` | Successfully completed |
| `cancelled` | Cancelled |

**Computed Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `progress` | Double | 0-1 completion percentage |
| `currentStep` | RecipeStepEntity? | Active step |
| `isCompleted` | Bool | Status == completed |
| `totalSteps` | Int | Number of steps |
| `totalCost` | Double | Recipe cost * quantity |
| `totalUnits` | Int | batchSize * quantity |
| `costPerUnit` | Double | Total cost / total units |
| `totalDuration` | TimeInterval | Start to completion time |

**Methods:**

| Method | Description |
|--------|-------------|
| `stepDuration(at:)` | Get duration for a specific step |
| `stepCompletionTime(at:)` | Get completion time for a step |
| `stepNote(at:)` | Get note for a specific step |
| `completeCurrentStep(note:)` | Mark current step done with optional note |
| `generateBatchNumber(existingBatches:)` | Static: create new batch number |

### CustomUnitEntity

Represents a user-defined measurement unit.

**File:** `Data/Entity/CustomUnitEntity.swift`

```swift
@Model
final class CustomUnitEntity {
    var symbol: String
    var name: String
    var createdAt: Date

    init(symbol: String, name: String) {
        self.symbol = symbol
        self.name = name
        self.createdAt = Date()
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `symbol` | String | Short symbol (e.g., "cup") |
| `name` | String | Full name (e.g., "Cup") |
| `createdAt` | Date | Creation timestamp |

## Constants

### InventoryUnit

Built-in measurement units.

**File:** `Data/Const/InventoryUnit.swift`

```swift
enum InventoryUnit: String, CaseIterable, Identifiable {
    case g
    case kg
    case ml
    case l
    case pcs

    var id: String { rawValue }

    var symbol: String { rawValue }

    var displayName: String {
        switch self {
        case .g: return String(localized: "Grams")
        case .kg: return String(localized: "Kilograms")
        case .ml: return String(localized: "Milliliters")
        case .l: return String(localized: "Liters")
        case .pcs: return String(localized: "Pieces")
        }
    }

    func convert(_ value: Double, to target: InventoryUnit) -> Double? {
        // Unit conversion logic
    }
}
```

**Units:**

| Case | Symbol | Display Name | Base Unit |
|------|--------|--------------|-----------|
| `g` | "g" | Grams | g (mass) |
| `kg` | "kg" | Kilograms | g (mass) |
| `ml` | "ml" | Milliliters | ml (volume) |
| `l` | "l" | Liters | ml (volume) |
| `pcs` | "pcs" | Pieces | pcs (count) |

**Conversion:**
- 1 kg = 1000 g
- 1 l = 1000 ml
- pcs cannot convert to other units

## Repositories

### RecipeRepository

**File:** `Data/Repositories/RecipeRepository.swift`

```swift
@MainActor
final class RecipeRepository {
    private let modelContext: ModelContext

    func fetchAll() -> Result<[RecipeEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<RecipeEntity, AppError>
    func search(name: String) -> Result<[RecipeEntity], AppError>
    func fetchFavorites() -> Result<[RecipeEntity], AppError>
    func fetchByCategory(_ category: String) -> Result<[RecipeEntity], AppError>
    func create(_ entity: RecipeEntity) -> Result<Void, AppError>
    func delete(_ entity: RecipeEntity) -> Result<Void, AppError>
    func updateBasicInfo(_ entity: RecipeEntity, ...) -> Result<Void, AppError>
    func rebuildRelationships(_ entity: RecipeEntity, steps:, ingredients:) -> Result<Void, AppError>
}
```

### InventoryRepository

**File:** `Data/Repositories/InventoryRepository.swift`

```swift
@MainActor
final class InventoryRepository {
    private let modelContext: ModelContext

    func fetchAll() -> Result<[InventoryEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<InventoryEntity, AppError>
    func search(name: String) -> Result<[InventoryEntity], AppError>
    func create(_ entity: InventoryEntity) -> Result<Void, AppError>
    func delete(_ entity: InventoryEntity) -> Result<Void, AppError>
    func fetchIngredients(for inventory: InventoryEntity) -> Result<[IngredientEntity], AppError>
    func deleteIngredient(_ ingredient: IngredientEntity) -> Result<Void, AppError>
}
```

### ManufacturingRepository

**File:** `Data/Repositories/ManufacturingRepository.swift`

```swift
@MainActor
final class ManufacturingRepository {
    private let modelContext: ModelContext

    func fetchAll() -> Result<[ManufacturingEntity], AppError>
    func fetchActive() -> Result<[ManufacturingEntity], AppError>
    func fetchCompleted() -> Result<[ManufacturingEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<ManufacturingEntity, AppError>
    func create(_ entity: ManufacturingEntity) -> Result<Void, AppError>
    func update() -> Result<Void, AppError>
    func delete(_ entity: ManufacturingEntity) -> Result<Void, AppError>
}
```

### CustomUnitRepository

**File:** `Data/Repositories/CustomUnitRepository.swift`

```swift
@MainActor
final class CustomUnitRepository {
    private let modelContext: ModelContext

    func fetchAll() -> Result<[CustomUnitEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<CustomUnitEntity, AppError>
    func fetchBySymbol(_ symbol: String) -> Result<CustomUnitEntity?, AppError>
    func create(_ entity: CustomUnitEntity) -> Result<Void, AppError>
    func delete(_ entity: CustomUnitEntity) -> Result<Void, AppError>
}
```

## Services

### CSVExportService

**File:** `Data/Services/CSVExportService.swift`

```swift
final class CSVExportService {
    static let shared = CSVExportService()

    func exportManufacturing(_ entity: ManufacturingEntity) -> URL?
    func exportAllManufacturing(_ entities: [ManufacturingEntity]) -> URL?
    func exportInventory(_ entities: [InventoryEntity]) -> URL?
    func exportRecipes(_ entities: [RecipeEntity]) -> URL?
}
```

**Features:**
- Singleton pattern for global access
- Lazy-loaded date formatters
- CSV escaping for special characters
- Temporary file generation
- Shareable URL creation

## Entity Relationships

```
┌─────────────────┐
│  RecipeEntity   │
├─────────────────┤
│ ingredients ────┼──┐
│ steps ──────────┼──┼─┐
└─────────────────┘  │ │
                     │ │
         ┌───────────┘ │
         │             │
         ▼             ▼
┌─────────────────┐  ┌─────────────────┐
│IngredientEntity │  │RecipeStepEntity │
├─────────────────┤  ├─────────────────┤
│ recipe (inverse)│  │ recipe (inverse)│
│ inventoryItem ──┼──┤                 │
└─────────────────┘  └─────────────────┘
         │
         ▼
┌─────────────────┐
│InventoryEntity  │
└─────────────────┘

┌─────────────────┐
│ManufacturingEnt │
├─────────────────┤
│ recipe ─────────┼──▶ RecipeEntity
└─────────────────┘

┌─────────────────┐
│CustomUnitEntity │
└─────────────────┘ (standalone)
```

## Delete Rules

| Relationship | Delete Rule |
|--------------|-------------|
| Recipe → Ingredients | Cascade |
| Recipe → Steps | Cascade |
| Ingredient → Recipe | Nullify (inverse) |
| Step → Recipe | Nullify (inverse) |
| Manufacturing → Recipe | No cascade |

## Best Practices

1. **Entity vs Presentation Models**
   - Use `@Model` entities for persistence
   - ViewModels transform entities for display

2. **Query Optimization**
   - Use `FetchDescriptor` with predicates
   - Sort at database level when possible

3. **Thread Safety**
   - Use `@MainActor` for UI-bound operations
   - Repositories are `@MainActor`

4. **Relationships**
   - Define delete rules appropriately
   - Use inverse relationships for consistency

5. **Error Handling**
   - Repositories return `Result<T, AppError>`
   - ViewModels handle errors gracefully
