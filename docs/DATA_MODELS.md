# Data Models

This document describes the data layer and models used in Anchan Factory.

## Overview

The app uses **SwiftData** for data persistence. All persistent models use the `@Model` macro.

## SwiftData Configuration

### AppModelContainer

Located in `Core/Database/AppModelContainer.swift`

```swift
@MainActor
let appModelContainer: ModelContainer = {
    let schema = Schema([
        RecipeEntity.self,
        InventoryEntity.self,
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

## Entities

### RecipeEntity

Represents a recipe in the system.

**File:** `Data/Entity/RecipeEntity.swift`

```swift
@Model
class RecipeEntity {
    var name: String

    init(name: String) {
        self.name = name
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Recipe name |

**Future Additions:**
- `ingredients: [IngredientEntity]` - Recipe ingredients
- `instructions: String` - Cooking instructions
- `servings: Int` - Number of servings
- `prepTime: TimeInterval` - Preparation time
- `cookTime: TimeInterval` - Cooking time
- `imageData: Data?` - Recipe image

### InventoryEntity

Represents an inventory item.

**File:** `Data/Entity/InventoryEntity.swift`

```swift
@Model
class InventoryEntity {
    var name: String

    init(name: String) {
        self.name = name
    }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Item name |

**Future Additions:**
- `quantity: Double` - Amount in stock
- `unit: InventoryUnit` - Measurement unit
- `minimumStock: Double` - Alert threshold
- `expiryDate: Date?` - Expiration date
- `category: String` - Item category

## Constants

### InventoryUnit

Enumeration of supported measurement units.

**File:** `Data/Const/InventoryUnit.swift`

```swift
enum InventoryUnit: String, CaseIterable, Identifiable {
    case g
    case kg
    case ml
    case l
    case pcs

    var id: String { rawValue }
}
```

**Units:**

| Case | Raw Value | Description |
|------|-----------|-------------|
| `g` | "g" | Grams |
| `kg` | "kg" | Kilograms |
| `ml` | "ml" | Milliliters |
| `l` | "l" | Liters |
| `pcs` | "pcs" | Pieces |

**Usage:**

```swift
let unit = InventoryUnit.kg
print(unit.rawValue) // "kg"

// Iterate all units
for unit in InventoryUnit.allCases {
    print(unit.rawValue)
}
```

## Presentation Models

### Recipe

View-layer model for recipe display.

**File:** `Presentation/Features/Recipe/Models/Recipe.swift`

```swift
struct Recipe: Identifiable, Hashable {
    var id: UUID
    var name: String
}
```

**Purpose:**
- Decouples views from database entities
- Provides `Identifiable` for SwiftUI lists
- Provides `Hashable` for navigation

## CRUD Operations

### Creating Records

```swift
@Environment(\.modelContext) private var modelContext

func createRecipe(name: String) {
    let recipe = RecipeEntity(name: name)
    modelContext.insert(recipe)
}
```

### Reading Records

```swift
@Query var recipes: [RecipeEntity]

// With predicate
@Query(filter: #Predicate<RecipeEntity> { recipe in
    recipe.name.contains("Pasta")
}) var pastaRecipes: [RecipeEntity]

// With sorting
@Query(sort: \RecipeEntity.name) var sortedRecipes: [RecipeEntity]
```

### Updating Records

```swift
func updateRecipe(_ recipe: RecipeEntity, newName: String) {
    recipe.name = newName
    // SwiftData auto-saves changes
}
```

### Deleting Records

```swift
func deleteRecipe(_ recipe: RecipeEntity) {
    modelContext.delete(recipe)
}
```

## Relationships (Future)

Example of how to add relationships:

```swift
@Model
class RecipeEntity {
    var name: String
    @Relationship(deleteRule: .cascade)
    var ingredients: [IngredientEntity]?

    init(name: String) {
        self.name = name
    }
}

@Model
class IngredientEntity {
    var name: String
    var quantity: Double
    var unit: String
    var recipe: RecipeEntity?

    init(name: String, quantity: Double, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
```

## Migration Strategy

When modifying models, SwiftData handles lightweight migrations automatically. For complex migrations:

```swift
let schema = Schema([
    RecipeEntity.self,
    InventoryEntity.self,
])

let migrationPlan = MigrationPlan(stages: [
    MigrationStage.lightweight(fromVersion: 1, toVersion: 2)
])

let configuration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false
)
```

## Best Practices

1. **Entity vs Presentation Models**
   - Use `@Model` entities for persistence
   - Use plain structs for view layer

2. **Query Optimization**
   - Use predicates to filter at database level
   - Limit results when displaying lists

3. **Thread Safety**
   - Use `@MainActor` for UI-bound operations
   - Create separate contexts for background work

4. **Relationships**
   - Define delete rules appropriately
   - Use optional relationships when appropriate

## Adding a New Entity

1. Create file in `Data/Entity/`:
   ```swift
   @Model
   class NewEntity {
       var field: Type

       init(field: Type) {
           self.field = field
       }
   }
   ```

2. Add to schema in `AppModelContainer.swift`:
   ```swift
   let schema = Schema([
       RecipeEntity.self,
       InventoryEntity.self,
       NewEntity.self,  // Add here
   ])
   ```

3. Create presentation model if needed in feature folder

4. Use `@Query` in views or fetch in ViewModels
