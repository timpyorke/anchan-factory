# Anchan Factory

A native iOS application for managing recipes and inventory, built with SwiftUI and SwiftData.

## Overview

Anchan Factory is a recipe and inventory management app designed to help users organize their recipes and track ingredients. The app provides a clean, modern interface with tab-based navigation and supports both iPhone and iPad devices.

## Requirements

- iOS 26.2+
- Xcode 16+
- Swift 5.0+

## Tech Stack

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| SwiftData | Data persistence |
| Swift Observation | Reactive state management |

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with a clean layer separation:

```
anchan/
├── App/                    # Application entry point
├── Core/                   # Shared utilities and infrastructure
│   ├── Database/           # SwiftData configuration
│   ├── Extension/          # Swift extensions
│   ├── Navigation/         # Routing and navigation
│   └── Widget/             # Reusable UI components
├── Data/                   # Data layer
│   ├── Const/              # Constants and enums
│   ├── Entity/             # SwiftData models
│   └── Repositories/       # Data access abstraction
├── Presentation/           # UI layer
│   └── Features/           # Feature modules
│       ├── Home/
│       ├── Recipe/
│       ├── RecipeDetail/
│       ├── Inventory/
│       └── Setting/
└── Resources/              # Assets and resources
```

## Features

### Tabs

| Tab | Description |
|-----|-------------|
| Home | Dashboard and quick navigation |
| Recipe | Recipe list and management |
| Inventory | Ingredient and stock tracking |
| Settings | App preferences and dark mode toggle |

### Navigation

The app uses a dual navigation system:

- **TabRouter** - Manages bottom tab bar navigation
- **StackRouter** - Handles push/pop navigation for detail screens

## Data Models

### RecipeEntity
```swift
@Model class RecipeEntity {
    var name: String
}
```

### InventoryEntity
```swift
@Model class InventoryEntity {
    var name: String
}
```

### InventoryUnit
Supported measurement units:
- `g` - grams
- `kg` - kilograms
- `ml` - milliliters
- `l` - liters
- `pcs` - pieces

## Getting Started

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd anchan-factory
   ```

2. Open the project in Xcode
   ```bash
   open anchan.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run (⌘+R)

## Project Structure Details

### Core Layer

| File | Purpose |
|------|---------|
| `AppModelContainer.swift` | SwiftData schema and container configuration |
| `AppRoute.swift` | Navigation route definitions |
| `AppTab.swift` | Tab bar item definitions |
| `StackRouter.swift` | NavigationStack state management |
| `TabRouter.swift` | Tab selection state management |
| `AppBarView.swift` | Reusable app bar component |
| `DoubleExtension.swift` | Number formatting utilities |

### Presentation Layer

Each feature module contains:
- `*View.swift` - SwiftUI view
- `*ViewModel.swift` - Observable view model with business logic

## Utilities

### Double Extension
```swift
let value = 5.0
print(value.clean) // "5"

let decimal = 5.25
print(decimal.clean) // "5.25"
```

## Configuration

| Setting | Value |
|---------|-------|
| Bundle ID | `com.codenour.anchan` |
| Version | 1.0 |
| Minimum iOS | 26.2 |
| Devices | only iPad |

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

## License

This project is proprietary software.

---

Built with SwiftUI and SwiftData
