# Architecture

This document describes the architecture of the Anchan Factory iOS application.

## Overview

Anchan Factory uses the **MVVM (Model-View-ViewModel)** architectural pattern with a clear separation of concerns across multiple layers.

## Layer Structure

```
┌─────────────────────────────────────────────────┐
│                 Presentation                     │
│  ┌──────────────────────────────────────────┐   │
│  │              Views (SwiftUI)              │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │          ViewModels (@Observable)         │   │
│  └──────────────────────────────────────────┘   │
├─────────────────────────────────────────────────┤
│                     Core                         │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐   │
│  │ Navigation │ │  Database  │ │  Widgets   │   │
│  └────────────┘ └────────────┘ └────────────┘   │
├─────────────────────────────────────────────────┤
│                     Data                         │
│  ┌──────────────────────────────────────────┐   │
│  │         Entities (SwiftData @Model)       │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │              Repositories                 │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

## Layers

### Presentation Layer

The presentation layer contains all UI-related code following the MVVM pattern.

**Views (`*View.swift`)**
- Built with SwiftUI
- Declarative UI definitions
- Bind to ViewModel state using `@State` and `@Bindable`
- No business logic

**ViewModels (`*ViewModel.swift`)**
- Use `@Observable` macro for reactivity
- Contain view-specific state and logic
- Handle user interactions
- Communicate with repositories (future)

```swift
@Observable
class FeatureViewModel {
    var state: State = .initial

    func handleAction() {
        // Business logic here
    }
}
```

### Core Layer

Shared infrastructure and utilities used across features.

**Database**
- `AppModelContainer.swift` - SwiftData configuration
- Defines schema with all entities
- Configures persistence storage

**Navigation**
- `AppRoute.swift` - Route enum for detail navigation
- `AppTab.swift` - Tab definitions
- `StackRouter.swift` - NavigationStack management
- `TabRouter.swift` - Tab selection management

**Widgets**
- Reusable UI components
- `AppBarView.swift` - Custom navigation bar

**Extensions**
- Swift extensions for common utilities
- `DoubleExtension.swift` - Number formatting

### Data Layer

Data persistence and business logic.

**Entities**
- SwiftData models using `@Model` macro
- Persisted to disk automatically
- Define data structure

**Constants**
- Enums and static values
- `InventoryUnit.swift` - Measurement units

**Repositories** (Planned)
- Abstract data access
- Handle CRUD operations
- Provide data to ViewModels

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
     │ (future)
     ▼
┌─────────────┐
│ Repository  │
└─────────────┘
     │
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
class ExampleViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?
}
```

### View Binding

```swift
struct ExampleView: View {
    @State var viewModel = ExampleViewModel()

    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
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
│  Path: [.recipeDetail(id: UUID)]        │
│                    │                     │
│                    ▼                     │
│  ┌───────────────────────────────────┐  │
│  │       RecipeDetailView             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Dependency Injection

Currently, dependencies are created inline. Future improvements could include:

- Protocol-based dependencies
- Environment-based injection
- Container-based DI

## Testing Strategy

Recommended testing approach:

| Layer | Test Type |
|-------|-----------|
| ViewModel | Unit Tests |
| Repository | Unit Tests |
| Entity | Unit Tests |
| View | UI Tests / Snapshot Tests |
| Integration | Integration Tests |

## Future Considerations

1. **Repository Pattern** - Implement for data access abstraction
2. **Coordinator Pattern** - For complex navigation flows
3. **Use Cases** - For complex business logic
4. **Dependency Injection** - For better testability
5. **Error Handling** - Centralized error management
