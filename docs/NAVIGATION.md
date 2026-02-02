# Navigation System

This document describes the navigation architecture used in Anchan Factory.

## Overview

The app uses a dual navigation system:
- **TabRouter** for bottom tab bar navigation
- **StackRouter** for push/pop navigation within each tab

Both routers use the `@Observable` macro for reactive state management and are injected into the view hierarchy via SwiftUI's `@Environment`.

## Tab Navigation

### AppTab

Defines the available tabs in the application.

**File:** `Core/Navigation/AppTab.swift`

```swift
enum AppTab: Hashable, CaseIterable {
    case home
    case recipe
    case inventory
    case setting
}
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `title` | String | Localized display name |
| `icon` | String | SF Symbol name |

**Tab Configuration:**

| Tab | Icon | Title |
|-----|------|-------|
| Home | `house.fill` | Home |
| Recipe | `book.fill` | Recipe |
| Inventory | `archivebox.fill` | Inventory |
| Setting | `gearshape.fill` | Setting |

### TabRouter

Manages the currently selected tab.

**File:** `Core/Navigation/TabRouter.swift`

```swift
@Observable
final class TabRouter {
    var selectedTab: AppTab = .home

    func go(to tab: AppTab) {
        selectedTab = tab
    }
}
```

**Usage:**

```swift
struct MainView: View {
    @State var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)
            // ... other tabs
        }
        .environment(tabRouter)
    }
}
```

## Stack Navigation

### AppRoute

Defines navigation destinations for detail screens.

**File:** `Core/Navigation/AppRoute.swift`

```swift
enum AppRoute: Hashable {
    case recipeAdd
    case recipeEdit(id: PersistentIdentifier)
    case recipeDetail(id: PersistentIdentifier)
    case manufacturingList
    case manufacturingProcess(id: PersistentIdentifier)
    case manufacturingDetail(id: PersistentIdentifier)
}
```

**Routes:**

| Route | Parameters | Description |
|-------|------------|-------------|
| `recipeAdd` | None | Create new recipe |
| `recipeEdit(id)` | PersistentIdentifier | Edit existing recipe |
| `recipeDetail(id)` | PersistentIdentifier | View recipe details |
| `manufacturingList` | None | All manufacturing history |
| `manufacturingProcess(id)` | PersistentIdentifier | Active manufacturing view |
| `manufacturingDetail(id)` | PersistentIdentifier | Completed manufacturing details |

**Adding New Routes:**

```swift
enum AppRoute: Hashable {
    // ... existing routes
    case newFeatureDetail(id: PersistentIdentifier)
    case newFeatureEdit(id: PersistentIdentifier)
}
```

### StackRouter

Manages the navigation stack for detail views.

**File:** `Core/Navigation/StackRouter.swift`

```swift
@Observable
final class StackRouter {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
}
```

**Methods:**

| Method | Description |
|--------|-------------|
| `push(_ route:)` | Navigate to a new screen |
| `pop()` | Go back one screen |
| `popToRoot()` | Return to root of current tab |

**Usage:**

```swift
struct MainView: View {
    @State var stackRouter = StackRouter()

    var body: some View {
        NavigationStack(path: $stackRouter.path) {
            ContentView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(stackRouter)
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .recipeAdd:
            RecipeEditView(mode: .create)
        case .recipeEdit(let id):
            RecipeEditView(mode: .edit(id: id))
        case .recipeDetail(let id):
            RecipeDetailView(id: id)
        case .manufacturingProcess(let id):
            ManufacturingView(id: id)
        case .manufacturingDetail(let id):
            ManufacturingDetailView(id: id)
        }
    }
}
```

## Navigation Patterns

### Navigating to a Detail Screen

```swift
struct RecipeView: View {
    @Environment(StackRouter.self) var stackRouter

    var body: some View {
        List(recipes) { recipe in
            Button {
                stackRouter.push(.recipeDetail(id: recipe.persistentModelID))
            } label: {
                RecipeRow(recipe: recipe)
            }
        }
    }
}
```

### Going Back

```swift
struct RecipeDetailView: View {
    @Environment(StackRouter.self) var stackRouter

    var body: some View {
        VStack {
            // Content
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    stackRouter.pop()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
```

### Switching Tabs

```swift
struct HomeView: View {
    @Environment(TabRouter.self) var tabRouter

    var body: some View {
        Button("View Inventory") {
            tabRouter.go(to: .inventory)
        }
    }
}
```

### Navigating After an Action

```swift
struct RecipeEditView: View {
    @Environment(StackRouter.self) var stackRouter

    func saveRecipe() {
        // Save logic...

        // Navigate back after saving
        stackRouter.pop()
    }
}
```

### Deep Navigation

```swift
struct HomeView: View {
    @Environment(StackRouter.self) var stackRouter

    func viewManufacturingDetails(batch: ManufacturingEntity) {
        stackRouter.push(.manufacturingDetail(id: batch.persistentModelID))
    }
}
```

## MainView Integration

The `MainView` combines both navigation systems:

```swift
struct MainView: View {
    @State var tabRouter = TabRouter()
    @State var stackRouter = StackRouter()

    var body: some View {
        NavigationStack(path: $stackRouter.path) {
            TabView(selection: $tabRouter.selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    tabContent(for: tab)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
        .environment(tabRouter)
        .environment(stackRouter)
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .recipe:
            RecipeView()
        case .inventory:
            InventoryView()
        case .setting:
            SettingView()
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .recipeAdd:
            RecipeEditView(mode: .create)
        case .recipeEdit(let id):
            RecipeEditView(mode: .edit(id: id))
        case .recipeDetail(let id):
            RecipeDetailView(id: id)
        case .manufacturingProcess(let id):
            ManufacturingView(id: id)
        case .manufacturingDetail(let id):
            ManufacturingDetailView(id: id)
        }
    }
}
```

## Best Practices

1. **Use Environment for Router Access**
   ```swift
   @Environment(StackRouter.self) var stackRouter
   @Environment(TabRouter.self) var tabRouter
   ```

2. **Keep Routes Simple**
   - Pass only `PersistentIdentifier`, not full objects
   - Let destination views fetch their own data

3. **Use PersistentIdentifier**
   - SwiftData's `PersistentIdentifier` is Hashable
   - Enables proper state restoration

4. **Programmatic Navigation**
   - Use StackRouter methods for imperative navigation
   - Avoid NavigationLink for complex flows

5. **Pop After Actions**
   - Pop navigation stack after save/delete operations
   - Provides clear user feedback

6. **Tab + Stack Coordination**
   - Both routers work independently
   - Stack navigation persists across tab switches

## Navigation Flow Examples

### Creating a New Recipe

```
Home Tab
    │
    └── "New Recipe" button
            │
            └── stackRouter.push(.recipeAdd)
                    │
                    └── RecipeEditView (create mode)
                            │
                            └── Save → stackRouter.pop()
                                    │
                                    └── Back to Home Tab
```

### Viewing Manufacturing Details

```
Home Tab
    │
    └── Tap manufacturing batch
            │
            └── stackRouter.push(.manufacturingDetail(id: ...))
                    │
                    └── ManufacturingDetailView
                            │
                            └── Back button → stackRouter.pop()
                                    │
                                    └── Back to Home Tab
```

### Editing a Recipe from Detail

```
Recipe Tab
    │
    └── Tap recipe
            │
            └── stackRouter.push(.recipeDetail(id: ...))
                    │
                    └── RecipeDetailView
                            │
                            └── Edit button
                                    │
                                    └── stackRouter.push(.recipeEdit(id: ...))
                                            │
                                            └── RecipeEditView (edit mode)
                                                    │
                                                    └── Save → stackRouter.popToRoot()
                                                            │
                                                            └── Back to Recipe Tab
```

## Adding a New Feature with Navigation

1. Add route to `AppRoute.swift`:
   ```swift
   case newFeature(id: PersistentIdentifier)
   ```

2. Add destination in `MainView`:
   ```swift
   case .newFeature(let id):
       NewFeatureView(id: id)
   ```

3. Navigate from any view:
   ```swift
   stackRouter.push(.newFeature(id: someId))
   ```

4. Handle back navigation in the new view:
   ```swift
   Button("Back") {
       stackRouter.pop()
   }
   ```
