# Development Guide

This guide covers development practices and conventions for Anchan Factory.

## Getting Started

### Prerequisites

- macOS 15+ (Sequoia)
- Xcode 16+
- iOS 26.2+ Simulator or Device

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd anchan-factory
   ```

2. Open project:
   ```bash
   open anchan.xcodeproj
   ```

3. Select a target device and run (⌘+R)

## Project Conventions

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| View | `*View.swift` | `HomeView.swift` |
| ViewModel | `*ViewModel.swift` | `HomeViewModel.swift` |
| Entity | `*Entity.swift` | `RecipeEntity.swift` |
| Repository | `*Repository.swift` | `RecipeRepository.swift` |
| Extension | `*Extension.swift` | `DoubleExtension.swift` |

### Folder Structure

```
Features/
└── FeatureName/
    ├── FeatureNameView.swift
    ├── FeatureNameViewModel.swift
    └── Models/
        └── FeatureModel.swift
```

### Code Style

**ViewModels:**
```swift
import Foundation
import Observation

@Observable
class FeatureViewModel {
    // MARK: - State
    var items: [Item] = []
    var isLoading = false

    // MARK: - Actions
    func loadItems() {
        // Implementation
    }
}
```

**Views:**
```swift
import SwiftUI

struct FeatureView: View {
    @State var viewModel = FeatureViewModel()

    var body: some View {
        content
            .onAppear {
                viewModel.loadItems()
            }
    }

    private var content: some View {
        // View implementation
    }
}
```

## Creating a New Feature

### Step 1: Create Feature Folder

```
Presentation/Features/NewFeature/
├── NewFeatureView.swift
├── NewFeatureViewModel.swift
└── Models/
    └── NewFeatureModel.swift (if needed)
```

### Step 2: Implement ViewModel

```swift
import Foundation
import Observation
import SwiftData

@Observable
class NewFeatureViewModel {
    var data: [DataItem] = []
    var isLoading = false
    var errorMessage: String?

    func loadData() {
        isLoading = true
        // Load data
        isLoading = false
    }

    func handleAction() {
        // Handle user action
    }
}
```

### Step 3: Implement View

```swift
import SwiftUI

struct NewFeatureView: View {
    @State var viewModel = NewFeatureViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                mainContent
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var mainContent: some View {
        List(viewModel.data) { item in
            Text(item.name)
        }
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
        // ...
        case .newFeature: return "New"
        }
    }

    var icon: String {
        switch self {
        // ...
        case .newFeature: return "star.fill"
        }
    }
}
```

### Step 5: Add Route (for detail screens)

In `Core/Navigation/AppRoute.swift`:
```swift
enum AppRoute: Hashable {
    case recipeDetail(id: UUID)
    case newFeatureDetail(id: UUID)  // Add new route
}
```

In `MainView.swift` add destination:
```swift
.navigationDestination(for: AppRoute.self) { route in
    switch route {
    case .recipeDetail(let id):
        RecipeDetailView(id: id)
    case .newFeatureDetail(let id):
        NewFeatureDetailView(id: id)
    }
}
```

## Working with SwiftData

### Adding an Entity

1. Create entity file:
   ```swift
   import SwiftData

   @Model
   class NewEntity {
       var name: String
       var createdAt: Date

       init(name: String) {
           self.name = name
           self.createdAt = Date()
       }
   }
   ```

2. Register in container (`AppModelContainer.swift`):
   ```swift
   let schema = Schema([
       RecipeEntity.self,
       InventoryEntity.self,
       NewEntity.self,  // Add here
   ])
   ```

### Querying Data

In Views with `@Query`:
```swift
struct MyView: View {
    @Query(sort: \RecipeEntity.name) var recipes: [RecipeEntity]

    var body: some View {
        List(recipes) { recipe in
            Text(recipe.name)
        }
    }
}
```

In ViewModels with ModelContext:
```swift
@Observable
class MyViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchRecipes() -> [RecipeEntity] {
        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
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
        Button("Back") { /* action */ }
    },
    trailing: {
        Button("Add") { /* action */ }
    }
)
```

### Extensions

**Double.clean** - Format numbers cleanly:
```swift
let whole = 5.0
print(whole.clean) // "5"

let decimal = 3.14
print(decimal.clean) // "3.14"
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

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Observation](https://developer.apple.com/documentation/observation)
