# Navigation System

This document describes the navigation architecture used in Anchan Factory.

## Overview

The app uses a dual navigation system:
- **TabRouter** for bottom tab bar navigation
- **StackRouter** for push/pop navigation within each tab

## Tab Navigation

### AppTab

Defines the available tabs in the application.

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
| `title` | String | Display name for the tab |
| `icon` | String | SF Symbol name |

**Tab Icons:**

| Tab | Icon | Title |
|-----|------|-------|
| Home | `house.fill` | Home |
| Recipe | `book.fill` | Recipe |
| Inventory | `archivebox.fill` | Inventory |
| Setting | `gearshape.fill` | Setting |

### TabRouter

Manages the currently selected tab.

```swift
@Observable
class TabRouter {
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
                .tag(AppTab.home)
            // ...
        }
    }
}
```

## Stack Navigation

### AppRoute

Defines navigation destinations for detail screens.

```swift
enum AppRoute: Hashable {
    case recipeDetail(id: UUID)
}
```

**Adding New Routes:**

```swift
enum AppRoute: Hashable {
    case recipeDetail(id: UUID)
    case ingredientDetail(id: UUID)  // New route
    case editRecipe(id: UUID)        // New route
}
```

### StackRouter

Manages the navigation stack for detail views.

```swift
@Observable
class StackRouter {
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

**Usage:**

```swift
struct MainView: View {
    @State var stackRouter = StackRouter()

    var body: some View {
        NavigationStack(path: $stackRouter.path) {
            ContentView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .recipeDetail(let id):
                        RecipeDetailView(id: id)
                    }
                }
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
        Button("View Recipe") {
            stackRouter.push(.recipeDetail(id: recipe.id))
        }
    }
}
```

### Going Back

```swift
struct RecipeDetailView: View {
    @Environment(StackRouter.self) var stackRouter

    var body: some View {
        Button("Back") {
            stackRouter.pop()
        }
    }
}
```

### Switching Tabs

```swift
struct HomeView: View {
    @Environment(TabRouter.self) var tabRouter

    var body: some View {
        Button("Go to Inventory") {
            tabRouter.go(to: .inventory)
        }
    }
}
```

## MainView Integration

The `MainView` combines both navigation systems:

```swift
struct MainView: View {
    @State var viewModel = MainViewModel()
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
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .recipeDetail(let id):
            RecipeDetailView(id: id)
        }
    }
}
```

## Best Practices

1. **Use Environment for Router Access**
   ```swift
   @Environment(StackRouter.self) var stackRouter
   ```

2. **Keep Routes Simple**
   - Pass only IDs, not full objects
   - Let destination views fetch their own data

3. **Programmatic Navigation**
   - Use StackRouter methods for imperative navigation
   - Use NavigationLink for declarative navigation

4. **Deep Linking Support**
   - Routes are Hashable for state restoration
   - Path can be serialized/deserialized

## Adding a New Feature with Navigation

1. Add route to `AppRoute.swift`:
   ```swift
   case newFeature(id: UUID)
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
