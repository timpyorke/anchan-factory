# Architecture

This document describes the architecture of the Anchan Factory iOS application.

## Overview

Anchan Factory uses the **MVVM (Model-View-ViewModel)** architectural pattern with Clean Architecture principles and a clear separation of concerns across multiple layers.

## Layer Structure

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                       │
│  ┌────────────────────────────────────────────────┐ │
│  │              Views (SwiftUI)                    │ │
│  └────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────┐ │
│  │          ViewModels (@Observable)               │ │
│  └────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│                       Core                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │Navigation│ │ Database │ │Formatters│ │Settings│ │
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ Widgets  │ │Utilities │ │  State   │            │
│  └──────────┘ └──────────┘ └──────────┘            │
├─────────────────────────────────────────────────────┤
│                       Data                           │
│  ┌────────────────────────────────────────────────┐ │
│  │          Entities (SwiftData @Model)            │ │
│  └────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────┐ │
│  │               Repositories                      │ │
│  └────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────┐ │
│  │                Services                         │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## Layers

### Presentation Layer

The presentation layer contains all UI-related code following the MVVM pattern.

**Views (`*View.swift`)**
- Built with SwiftUI
- Declarative UI definitions
- Bind to ViewModel state using `@State` and `@Bindable`
- No business logic
- Use `@Environment` for router access

**ViewModels (`*ViewModel.swift`)**
- Use `@Observable` macro for reactivity
- Use `@MainActor` for thread safety
- Contain view-specific state and logic
- Handle user interactions
- Communicate with repositories
- Error handling with `AppError`

```swift
@Observable
@MainActor
final class FeatureViewModel {
    // Data state
    private(set) var items: [Entity] = []

    // UI state
    var isLoading = false
    var errorMessage: String?
    var showError = false

    // Dependencies
    private var repository: Repository?

    func setup(modelContext: ModelContext) {
        self.repository = Repository(modelContext: modelContext)
    }

    func loadData() {
        switch repository?.fetchAll() {
        case .success(let data):
            items = data
        case .failure(let error):
            handleError(error)
        case .none:
            break
        }
    }

    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

### Core Layer

Shared infrastructure and utilities used across features.

**Database**
- `AppModelContainer.swift` - SwiftData configuration with schema

**Navigation**
- `AppRoute.swift` - Route enum for detail navigation
- `AppTab.swift` - Tab definitions
- `StackRouter.swift` - NavigationStack management
- `TabRouter.swift` - Tab selection management

**Formatters**
- `CurrencyFormatter.swift` - Thai Baht formatting (฿)
- `TimeFormatter.swift` - Duration formatting (h, m)
- `AppNumberFormatter.swift` - Decimal formatting

**Utilities**
- `QuantityCalculator.swift` - Unit conversions
- `StringUtilities.swift` - String helpers

**Constants**
- `AppSettings.swift` - User preferences (singleton)
- `AppTheme.swift` - Theme modes
- `AppLanguage.swift` - Localization
- `AppError.swift` - Error handling enum

**Widgets**
- `AppBarView.swift` - Custom navigation bar
- `TimePickerView.swift` - Time input component

**Extensions**
- `IntExtension.swift` - Integer utilities
- `DoubleExtension.swift` - Number formatting

### Data Layer

Data persistence, access, and business logic.

**Entities**
- SwiftData models using `@Model` macro
- Persisted to disk automatically
- Define relationships with `@Relationship`
- Computed properties for derived data

**Repositories**
- Protocol-based for testability
- Abstract data access
- Handle CRUD operations
- Return `Result<T, AppError>` for error handling
- Use `@MainActor` for thread safety

**Services**
- `CSVExportService.swift` - Export data to CSV files

## Data Flow

```
User Action
     │
     ▼
┌─────────┐
│  View   │ ──── observes ────┐
└─────────┘                   │
     │                        │
     │ calls                  │
     ▼                        ▼
┌─────────────┐         ┌──────────┐
│  ViewModel  │ ───────▶│  State   │
└─────────────┘ updates └──────────┘
     │
     │ uses
     ▼
┌─────────────┐
│ Repository  │
└─────────────┘
     │
     │ persists
     ▼
┌─────────────┐
│  SwiftData  │
└─────────────┘
```

## State Management

The app uses Swift's `@Observable` macro for reactive state management.

### Observable Pattern

```swift
@Observable
@MainActor
final class ExampleViewModel {
    private(set) var items: [Item] = []
    var isLoading = false
    var searchText = ""
    var showError = false
    var errorMessage: String?

    private var repository: ItemRepository?

    func setup(modelContext: ModelContext) {
        repository = ItemRepository(modelContext: modelContext)
    }

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
```

### View Binding

```swift
struct ExampleView: View {
    @State var viewModel = ExampleViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(viewModel.filteredItems) { item in
            Text(item.name)
        }
        .searchable(text: $viewModel.searchText)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
            viewModel.loadData()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
```

## Navigation Architecture

### Tab Navigation

```
┌─────────────────────────────────────────┐
│                MainView                  │
│  ┌───────────────────────────────────┐  │
│  │           TabView                  │  │
│  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐     │  │
│  │  │Home│ │Rcp │ │Inv │ │Set │     │  │
│  │  └────┘ └────┘ └────┘ └────┘     │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ┌───────────────────────────────────┐  │
│  │          TabRouter                 │  │
│  │     (manages selected tab)         │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Stack Navigation

```
┌─────────────────────────────────────────┐
│            NavigationStack               │
│  ┌───────────────────────────────────┐  │
│  │          StackRouter               │  │
│  │      (manages path array)          │  │
│  └───────────────────────────────────┘  │
│                                          │
│  Routes:                                 │
│  - recipeAdd                            │
│  - recipeEdit(id)                       │
│  - recipeDetail(id)                     │
│  - manufacturingProcess(id)             │
│  - manufacturingDetail(id)              │
│                                          │
│  Path: [.recipeDetail(id)]              │
│                    │                     │
│                    ▼                     │
│  ┌───────────────────────────────────┐  │
│  │       RecipeDetailView             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Repository Pattern

All repositories follow a consistent pattern:

```swift
protocol RecipeRepositoryProtocol {
    func fetchAll() -> Result<[RecipeEntity], AppError>
    func fetch(by id: PersistentIdentifier) -> Result<RecipeEntity, AppError>
    func create(_ entity: RecipeEntity) -> Result<Void, AppError>
    func delete(_ entity: RecipeEntity) -> Result<Void, AppError>
}

@MainActor
final class RecipeRepository: RecipeRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> Result<[RecipeEntity], AppError> {
        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            let results = try modelContext.fetch(descriptor)
            return .success(results)
        } catch {
            return .failure(.databaseError)
        }
    }
    // ... other methods
}
```

## Error Handling

Centralized error management with `AppError`:

```swift
enum AppError: Error, LocalizedError {
    case databaseError
    case validationError
    case exportError
    case notFound
    case insufficientStock
    case unknown

    var errorDescription: String? {
        switch self {
        case .databaseError:
            return String(localized: "Database operation failed")
        case .validationError:
            return String(localized: "Invalid input")
        case .exportError:
            return String(localized: "Export failed")
        case .notFound:
            return String(localized: "Item not found")
        case .insufficientStock:
            return String(localized: "Insufficient stock")
        case .unknown:
            return String(localized: "An error occurred")
        }
    }

    var recoverySuggestion: String? {
        // Recovery suggestions for each error type
    }
}
```

## Dependency Injection

Dependencies are injected via:

1. **ModelContext** - Passed to ViewModels via `setup()` method
2. **Environment** - Used for navigation routers
3. **Constructor** - Repository injection

```swift
struct FeatureView: View {
    @State var viewModel = FeatureViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) var stackRouter

    var body: some View {
        // View content
    }
    .onAppear {
        viewModel.setup(modelContext: modelContext)
    }
}
```

## Testing Strategy

| Layer | Test Type |
|-------|-----------|
| ViewModel | Unit Tests |
| Repository | Unit Tests (protocol-based mocking) |
| Entity | Unit Tests |
| View | UI Tests / Snapshot Tests |
| Integration | Integration Tests |

## Implemented Features

- [x] Repository Pattern for data access
- [x] Error Handling with AppError enum
- [x] Dependency Injection via setup methods
- [x] Navigation with TabRouter and StackRouter
- [x] CSV Export Service
- [x] Formatters for currency, time, numbers
- [x] Settings persistence with UserDefaults
- [x] Localization (English/Thai)
- [x] Theme support (System/Light/Dark)
