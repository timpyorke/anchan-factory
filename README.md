# Anchan Factory

A native iOS application for manufacturing management, recipe tracking, and inventory control, built with SwiftUI and SwiftData.

## Overview

Anchan Factory is a comprehensive manufacturing and inventory management app designed for production environments. It enables users to create recipes with ingredients and steps, track inventory levels, manage manufacturing batches, and monitor production costs. The app provides a clean, modern interface with tab-based navigation optimized for iPad devices.

## Requirements

- iOS 26.2+
- Xcode 16+
- Swift 5.9+

## Tech Stack

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| SwiftData | Data persistence (ORM) |
| Swift Observation | Reactive state management (@Observable) |
| Foundation | Date formatting, localization |

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with Clean Architecture principles:

```
anchan/
├── App/                    # Application entry point
│   └── AnchanApp.swift
├── Core/                   # Shared utilities and infrastructure
│   ├── Const/              # App settings, themes, language, errors
│   ├── Database/           # SwiftData configuration
│   ├── Extensions/         # Swift extensions
│   ├── Formatters/         # Currency, time, number formatters
│   ├── Navigation/         # Routing and navigation
│   ├── State/              # Loading states
│   ├── Utilities/          # Quantity calculator, string utilities
│   └── Widgets/            # Reusable UI components
├── Data/                   # Data layer
│   ├── Const/              # Inventory units
│   ├── Entity/             # SwiftData models
│   ├── Repositories/       # Data access abstraction
│   └── Services/           # CSV export service
├── Presentation/           # UI layer
│   └── Features/           # Feature modules
│       ├── Home/           # Dashboard
│       ├── Inventory/      # Stock management
│       ├── Manufacturing/  # Production tracking
│       ├── Recipe/         # Recipe list
│       ├── RecipeDetail/   # Recipe details
│       └── Setting/        # App preferences
└── Resources/              # Assets and localization
```

## Features

### Tabs

| Tab | Description |
|-----|-------------|
| Home | Dashboard with stats, active manufacturing, low stock alerts |
| Recipe | Recipe management with ingredients and steps |
| Inventory | Stock tracking with units and pricing |
| Settings | Theme, language, custom units, data export |

### Core Features

**Manufacturing Management**
- Create manufacturing batches from recipes
- Track production progress step by step
- Auto-generate batch numbers (YYMMDD-XXX format)
- Automatic inventory deduction upon completion
- Export manufacturing data to CSV

**Recipe Management**
- Create recipes with ingredients and timed steps
- Cost calculation (total and per-unit)
- Batch size and output unit configuration
- Ingredient sufficiency checking
- Favorites and categories

**Inventory Management**
- Track stock levels with min/max thresholds
- Support for built-in units (g, kg, ml, l, pcs)
- Custom units creation
- Low stock alerts
- Unit price tracking

**Dashboard**
- Summary statistics (batches, inventory, costs)
- Active manufacturing progress
- Low stock warnings
- Recently completed batches

### Navigation

The app uses a dual navigation system:

- **TabRouter** - Manages bottom tab bar navigation
- **StackRouter** - Handles push/pop navigation for detail screens

## Data Models

### RecipeEntity
```swift
@Model class RecipeEntity {
    var name: String
    var note: String
    var category: String?
    var isFavorite: Bool
    var batchSize: Int
    var batchUnit: String
    var createdAt: Date
    @Relationship var ingredients: [IngredientEntity]
    @Relationship var steps: [RecipeStepEntity]
}
```

### InventoryEntity
```swift
@Model class InventoryEntity {
    var name: String
    var category: String?
    var unitSymbol: String
    var unitPrice: Double
    var stock: Double
    var minStock: Double
    var createdAt: Date
}
```

### ManufacturingEntity
```swift
@Model class ManufacturingEntity {
    var batchNumber: String
    var status: ManufacturingStatus
    var currentStepIndex: Int
    var quantity: Int
    var startedAt: Date
    var completedAt: Date?
    @Relationship var recipe: RecipeEntity
}
```

### InventoryUnit
Supported measurement units:
- `g` - grams
- `kg` - kilograms
- `ml` - milliliters
- `l` - liters
- `pcs` - pieces
- Custom units via `CustomUnitEntity`

## Getting Started

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd anchan
   ```

2. Open the project in Xcode
   ```bash
   open anchan.xcodeproj
   ```

3. Select your target device or simulator (iPad recommended)

4. Build and run (⌘+R)

## Project Structure Details

### Core Layer

| File | Purpose |
|------|---------|
| `AppModelContainer.swift` | SwiftData schema and container |
| `AppRoute.swift` | Navigation route definitions |
| `AppTab.swift` | Tab bar item definitions |
| `StackRouter.swift` | NavigationStack state management |
| `TabRouter.swift` | Tab selection state management |
| `AppSettings.swift` | User preferences (singleton) |
| `AppTheme.swift` | Theme modes (system/light/dark) |
| `AppLanguage.swift` | Language support (en/th) |
| `AppError.swift` | Error handling enum |
| `CurrencyFormatter.swift` | Thai Baht formatting |
| `TimeFormatter.swift` | Duration formatting |
| `QuantityCalculator.swift` | Unit conversion |

### Data Layer

| File | Purpose |
|------|---------|
| `RecipeRepository.swift` | Recipe CRUD operations |
| `InventoryRepository.swift` | Inventory CRUD operations |
| `ManufacturingRepository.swift` | Manufacturing CRUD operations |
| `CustomUnitRepository.swift` | Custom unit management |
| `CSVExportService.swift` | Data export to CSV |

### Presentation Layer

Each feature module contains:
- `*View.swift` - SwiftUI view
- `*ViewModel.swift` - Observable view model with business logic

## Configuration

| Setting | Value |
|---------|-------|
| Bundle ID | `com.codenour.anchan` |
| Version | 1.0 |
| Minimum iOS | 26.2 |
| Devices | iPad only |
| Languages | English, Thai |

## Development

### Adding a New Feature

1. Create a new folder under `Presentation/Features/`
2. Add `*View.swift` and `*ViewModel.swift`
3. If the feature needs a tab, add a case to `AppTab.swift`
4. For detail navigation, add a route to `AppRoute.swift`

### Adding a New Entity

1. Create the entity in `Data/Entity/`
2. Use the `@Model` macro for SwiftData persistence
3. Add the entity to the schema in `AppModelContainer.swift`
4. Create a repository in `Data/Repositories/`

## License

This project is proprietary software.

---

Built with SwiftUI and SwiftData
