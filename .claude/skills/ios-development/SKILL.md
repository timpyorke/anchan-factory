---
name: ios-development
description: Guides iOS app development for the Anchan project using SwiftUI, Swift Data, and @Observable. Use when building features, adding views, creating entities, or implementing navigation.
---

Follow the **Anchan** project architecture and conventions:

## Project Structure

```
anchan/
├── App/                    # App entry point (AnchanApp.swift)
├── Core/                   # Shared infrastructure
│   ├── Database/           # AppModelContainer
│   ├── Extension/          # Swift extensions
│   ├── Navigation/         # Routers (StackRouter, TabRouter, AppRoute)
│   └── Widget/             # Reusable UI components
├── Data/                   # Data layer
│   ├── Const/              # Constants
│   ├── Entity/             # Swift Data @Model entities
│   └── Repositories/       # Repository pattern for data access
├── Presentation/           # UI layer
│   └── Features/           # Feature modules (View + ViewModel pairs)
└── Resources/              # Assets, fonts, etc.
```

## Conventions

### 1. Navigation (StackRouter + TabRouter)
- Use `@Observable` classes for routing state
- Define routes in `AppRoute` enum with associated values
- Pass `StackRouter` to views that need navigation
- Use `.navigationDestination(for: AppRoute.self)` for routing

### 2. Swift Data Entities
- Name entities with `Entity` suffix (e.g., `RecipeEntity`)
- Use `@Model` macro
- Define relationships with `@Relationship(deleteRule:)`
- Add computed properties for derived data

### 3. Repositories
- Create protocol first (e.g., `RecipeRepositoryProtocol`)
- Mark implementation with `@MainActor`
- Inject `ModelContext` via initializer
- Use `FetchDescriptor` with `#Predicate` for queries

### 4. ViewModels
- Use `@Observable` + `@MainActor` macros
- Mark state properties with `private(set)` for read-only access
- Create `setup(modelContext:)` method for dependency injection
- Use `// MARK:` comments for organization (State, Dependencies, Computed, Actions)

### 5. Views
- Use `@State` for local ViewModel instances
- Call `viewModel.setup(modelContext:)` in `.onAppear`
- Pass routers via initializer, not environment
- Extract reusable widgets to `Core/Widget/`

## Quick Reference

| Pattern | Example |
|---------|---------|
| New Entity | `Data/Entity/[Name]Entity.swift` with `@Model` |
| New Repository | `Data/Repositories/[Name]Repository.swift` with protocol |
| New Feature | `Presentation/Features/[Name]/` with View + ViewModel |
| New Route | Add case to `AppRoute` enum, handle in `MainView` |
| New Widget | `Core/Widget/[Name]View.swift` |

**Gotcha**: Always use `PersistentIdentifier` (not the entity directly) when passing Swift Data models through navigation routes!
