# Development Guide

This guide covers development practices and conventions for Anchan Factory.

## Getting Started

### Prerequisites

- macOS 15+ (Sequoia)
- Xcode 16+
- iOS 26.2+ Simulator or Device (iPad)

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd anchan
   ```

2. Open project:
   ```bash
   open anchan.xcodeproj
   ```

3. Select an iPad target device and run (⌘+R)

## Project Conventions

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| View | `*View.swift` | `HomeView.swift` |
| ViewModel | `*ViewModel.swift` | `HomeViewModel.swift` |
| Entity | `*Entity.swift` | `RecipeEntity.swift` |
| Repository | `*Repository.swift` | `RecipeRepository.swift` |
| Service | `*Service.swift` | `CSVExportService.swift` |
| Extension | `*Extension.swift` | `DoubleExtension.swift` |
| Formatter | `*Formatter.swift` | `CurrencyFormatter.swift` |

### Folder Structure

```
Features/
└── FeatureName/
    ├── FeatureNameView.swift
    ├── FeatureNameViewModel.swift
    └── Components/
        └── FeatureComponent.swift
```

### Code Style

**ViewModels:**
```swift
import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class FeatureViewModel {
    // MARK: - Data State
    private(set) var items: [Entity] = []

    // MARK: - UI State
    var isLoading = false
    var searchText = ""
    var showError = false
    var errorMessage: String?

    // MARK: - Dependencies
    private var repository: Repository?

    // MARK: - Setup
    func setup(modelContext: ModelContext) {
        repository = Repository(modelContext: modelContext)
    }

    // MARK: - Actions
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

    // MARK: - Computed Properties
    var filteredItems: [Entity] {
        if searchText.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Error Handling
    private func handleError(_ error: AppError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

**Views:**
```swift
import SwiftUI

struct FeatureView: View {
    @State var viewModel = FeatureViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) var stackRouter

    var body: some View {
        content
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

    private var content: some View {
        List(viewModel.filteredItems) { item in
            Text(item.name)
        }
        .searchable(text: $viewModel.searchText)
    }
}
```

## Creating a New Feature

### Step 1: Create Feature Folder

```
Presentation/Features/NewFeature/
├── NewFeatureView.swift
├── NewFeatureViewModel.swift
└── Components/
    └── NewFeatureRow.swift (if needed)
```

### Step 2: Implement ViewModel

```swift
import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class NewFeatureViewModel {
    // Data state
    private(set) var data: [DataItem] = []

    // UI state
    var isLoading = false
    var showError = false
    var errorMessage: String?

    // Dependencies
    private var repository: DataRepository?

    func setup(modelContext: ModelContext) {
        repository = DataRepository(modelContext: modelContext)
    }

    func loadData() {
        switch repository?.fetchAll() {
        case .success(let items):
            data = items
        case .failure(let error):
            handleError(error)
        case .none:
            break
        }
    }

    func createItem(name: String) {
        let item = DataEntity(name: name)
        switch repository?.create(item) {
        case .success:
            loadData()
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

### Step 3: Implement View

```swift
import SwiftUI

struct NewFeatureView: View {
    @State var viewModel = NewFeatureViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.data.isEmpty {
                emptyState
            } else {
                mainContent
            }
        }
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

    private var mainContent: some View {
        List(viewModel.data) { item in
            Text(item.name)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Items",
            systemImage: "tray",
            description: Text("Add your first item to get started")
        )
    }
}
```

### Step 4: Add Tab (if needed)

In `Core/Navigation/AppTab.swift`:
```swift
enum AppTab: Hashable, CaseIterable {
    case home
    case recipe
    case inventory
    case setting
    case newFeature  // Add new case

    var title: String {
        switch self {
        // ...existing cases
        case .newFeature: return String(localized: "New Feature")
        }
    }

    var icon: String {
        switch self {
        // ...existing cases
        case .newFeature: return "star.fill"
        }
    }
}
```

### Step 5: Add Route (for detail screens)

In `Core/Navigation/AppRoute.swift`:
```swift
enum AppRoute: Hashable {
    case recipeAdd
    case recipeEdit(id: PersistentIdentifier)
    case recipeDetail(id: PersistentIdentifier)
    case manufacturingProcess(id: PersistentIdentifier)
    case manufacturingDetail(id: PersistentIdentifier)
    case newFeatureDetail(id: PersistentIdentifier)  // Add new route
}
```

In `MainView.swift` add destination:
```swift
.navigationDestination(for: AppRoute.self) { route in
    switch route {
    // ...existing cases
    case .newFeatureDetail(let id):
        NewFeatureDetailView(id: id)
    }
}
```

## Working with SwiftData

### Adding an Entity

1. Create entity file in `Data/Entity/`:
   ```swift
   import SwiftData

   @Model
   final class NewEntity {
       var name: String
       var createdAt: Date

       init(name: String) {
           self.name = name
           self.createdAt = Date()
       }
   }
   ```

2. Register in container (`Core/Database/AppModelContainer.swift`):
   ```swift
   let schema = Schema([
       RecipeEntity.self,
       RecipeStepEntity.self,
       IngredientEntity.self,
       InventoryEntity.self,
       ManufacturingEntity.self,
       CustomUnitEntity.self,
       NewEntity.self,  // Add here
   ])
   ```

3. Create repository in `Data/Repositories/`:
   ```swift
   @MainActor
   final class NewEntityRepository {
       private let modelContext: ModelContext

       init(modelContext: ModelContext) {
           self.modelContext = modelContext
       }

       func fetchAll() -> Result<[NewEntity], AppError> {
           let descriptor = FetchDescriptor<NewEntity>(
               sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
           )
           do {
               let results = try modelContext.fetch(descriptor)
               return .success(results)
           } catch {
               return .failure(.databaseError)
           }
       }

       func create(_ entity: NewEntity) -> Result<Void, AppError> {
           modelContext.insert(entity)
           return .success(())
       }

       func delete(_ entity: NewEntity) -> Result<Void, AppError> {
           modelContext.delete(entity)
           return .success(())
       }
   }
   ```

### Querying Data

In ViewModels with Repository:
```swift
func loadData() {
    switch repository?.fetchAll() {
    case .success(let items):
        self.items = items
    case .failure(let error):
        handleError(error)
    case .none:
        break
    }
}
```

With predicates:
```swift
func search(name: String) -> Result<[RecipeEntity], AppError> {
    let descriptor = FetchDescriptor<RecipeEntity>(
        predicate: #Predicate { $0.name.localizedStandardContains(name) },
        sortBy: [SortDescriptor(\.name)]
    )
    do {
        let results = try modelContext.fetch(descriptor)
        return .success(results)
    } catch {
        return .failure(.databaseError)
    }
}
```

## Reusable Components

### AppBarView

Custom navigation bar with leading/trailing actions:

```swift
AppBarView(
    title: "My Screen",
    leading: {
        Button("Back") { stackRouter.pop() }
    },
    trailing: {
        Button("Add") { /* action */ }
    }
)
```

### TimePickerView

Time input component for recipe steps:

```swift
TimePickerView(minutes: $stepTime)
```

### Formatters

**CurrencyFormatter** - Format Thai Baht:
```swift
let formatted = CurrencyFormatter.format(150.50)  // "฿150.50"
```

**TimeFormatter** - Format durations:
```swift
let formatted = TimeFormatter.formatMinutes(90)  // "1h 30m"
let duration = TimeFormatter.formatDuration(3600)  // "1h 0m"
```

**AppNumberFormatter** - Format numbers:
```swift
let formatted = AppNumberFormatter.format(5.0)  // "5"
let decimal = AppNumberFormatter.format(5.25)   // "5.25"
```

### Extensions

**Double.clean** - Format numbers cleanly:
```swift
let whole = 5.0
print(whole.clean) // "5"

let decimal = 3.14
print(decimal.clean) // "3.14"
```

## Error Handling

Use the `AppError` enum for consistent error handling:

```swift
enum AppError: Error, LocalizedError {
    case databaseError
    case validationError
    case exportError
    case notFound
    case insufficientStock
    case unknown
}
```

In ViewModels:
```swift
private func handleError(_ error: AppError) {
    errorMessage = error.localizedDescription
    showError = true
}
```

In Views:
```swift
.alert("Error", isPresented: $viewModel.showError) {
    Button("OK") { }
} message: {
    Text(viewModel.errorMessage ?? "")
}
```

## Localization

Use `String(localized:)` for all user-facing text:

```swift
let title = String(localized: "Recipe")
let message = String(localized: "Are you sure you want to delete?")
```

The app supports:
- English (en)
- Thai (th)

Language preference is stored in `AppSettings.shared.language`.

## Settings

Access app settings via `AppSettings.shared`:

```swift
// Theme
AppSettings.shared.theme = .dark

// Language
AppSettings.shared.language = .thai
```

Settings are automatically persisted to UserDefaults.

## CSV Export

Use `CSVExportService` for data export:

```swift
// Export single manufacturing batch
if let url = CSVExportService.shared.exportManufacturing(batch) {
    // Share URL
}

// Export all inventory
if let url = CSVExportService.shared.exportInventory(items) {
    // Share URL
}
```

## Testing

### Unit Tests

Create tests in `anchanTests/` folder:

```swift
import XCTest
@testable import anchan

final class RecipeViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = RecipeViewModel()
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

### UI Tests

Create tests in `anchanUITests/` folder:

```swift
import XCTest

final class RecipeUITests: XCTestCase {
    func testNavigateToRecipeDetail() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Recipe"].tap()
        // Add assertions
    }
}
```

## Debugging

### SwiftData

View database file:
```bash
# Find the database file
find ~/Library/Developer/CoreSimulator -name "default.store" 2>/dev/null
```

### Logging

Use print for development debugging:
```swift
#if DEBUG
print("[ViewModel] Loading data...")
#endif
```

## Build Configuration

| Configuration | Use Case |
|--------------|----------|
| Debug | Development with debugging symbols |
| Release | App Store / Production builds |

## Common Issues

### SwiftData Not Saving

Ensure ModelContext is properly injected:
```swift
.modelContainer(appModelContainer)
```

### Navigation Not Working

Check route is registered in MainView:
```swift
.navigationDestination(for: AppRoute.self) { route in
    // All routes must be handled
}
```

### Observable Not Updating

Ensure using `@State` for ViewModel:
```swift
@State var viewModel = MyViewModel()  // Correct
var viewModel = MyViewModel()          // Wrong
```

### Repository Not Working

Ensure setup is called in onAppear:
```swift
.onAppear {
    viewModel.setup(modelContext: modelContext)
    viewModel.loadData()
}
```

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Observation](https://developer.apple.com/documentation/observation)
