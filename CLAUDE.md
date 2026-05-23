# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Daily Jolly (bundle id `com.codenour.anchan`) — a SwiftUI + SwiftData iPad app for manufacturing, recipe, and inventory management. The Xcode project name is `DailyJolly`; the repo directory name (`anchan-factory`) does not match. Targets iPad (`TARGETED_DEVICE_FAMILY = "1,2"`); the README claims iOS 26.2 but `IPHONEOS_DEPLOYMENT_TARGET` in the project is `17.0` — trust the pbxproj.

There is a sibling skill at `.claude/skills/ios-development/SKILL.md` describing project conventions; it is auto-loaded by the `ios-development` skill, so prefer invoking that skill (or following its rules) when adding views, entities, or repositories rather than re-deriving conventions.

## Build / Run / Test

Open the workspace in Xcode and use ⌘+R, or from CLI:

```bash
# Build
xcodebuild -project DailyJolly.xcodeproj -scheme DailyJolly -configuration Debug build

# Run tests (scheme `DailyJolly` has `DailyJollyTests` wired into TestAction)
xcodebuild -project DailyJolly.xcodeproj -scheme DailyJolly -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M4)' test

# Run a single test
xcodebuild -project DailyJolly.xcodeproj -scheme DailyJolly -destination '...' test -only-testing:DailyJollyTests/DailyJollyTests/testExample
```

`setup_tests.rb` and `update_scheme.rb` are one-time `xcodeproj` gem scripts that created the test target and wired it into the scheme; they should not need to be re-run.

CI is GitHub Actions: `.github/workflows/deploy-testflight.yml` ships `main` to TestFlight, `.github/workflows/deploy-firebase.yml` ships `develop` and `release/**` to Firebase App Distribution. Both archive via `xcodebuild archive` with manual signing.

## Architecture

MVVM + Clean Architecture in four layers under `DailyJolly/`:

- `App/` — `@main` entry; constructs `AppModelContainer` and injects via `.modelContainer(container)`.
- `Core/` — cross-cutting: `Database/` (SwiftData schema), `Navigation/` (routers + routes), `Const/` (settings, theme, language), `Error/AppError`, `Formatters/`, `Utilities/`, `Widget/` (reusable UI), `Extension/`, `State/`.
- `Data/` — `Entity/` (`@Model` types), `Repositories/` (protocol + `@MainActor` impl, return `Result<T, AppError>`), `Services/` (CSV import/export, production templates), `Const/` (`InventoryUnit`, `GellingAgentType`, `MeasurementType`).
- `Presentation/` — `Features/<Name>/<Name>View.swift` + `<Name>ViewModel.swift` pairs; `Components/` (shared inputs like `MeasurementInputView`, `PinEntryView`, `CameraPicker`); `MainView.swift` is the root TabView.

### SwiftData

All entities are registered in `Core/Database/AppModelContainer.swift` — **adding a new `@Model` requires adding it to the `Schema([...])` array** or the persistent store will not know about it. Relationships use `@Relationship(deleteRule: .cascade)` with inverse hints where needed (see `RecipeEntity.manufacturingRecords`).

**Gotcha:** Navigate by `PersistentIdentifier`, never by passing the entity directly. `AppRoute` cases all carry `id: PersistentIdentifier`, and views resolve them via `modelContext.model(for: id) as? Entity` inside the repository (`fetch(by:)`).

`RecipeRepository.rebuildRelationships` deletes-then-recreates steps/ingredients on edit and **must** save the context immediately so temporary IDs are promoted before the UI re-renders — comment in the file flags this as load-bearing.

### Navigation (dual-router)

`MainView` owns one `TabRouter` (selected tab) and one `StackRouter` (`path: [AppRoute]`). The `NavigationStack` wraps the `TabView`, and `.navigationDestination(for: AppRoute.self)` lives on the stack — so detail screens push above whichever tab is selected. Both routers are `@Observable` classes; pass them via initializer (the `stackRouter` is also placed in `.environment(stackRouter)` for descendants).

To add a route: append a case to `AppRoute`, then add a `case` to the `switch` in `MainView.navigationDestination`.

### ViewModel pattern

```swift
@Observable @MainActor
final class FooViewModel {
    // MARK: - State
    private(set) var items: [FooEntity] = []
    // MARK: - UI State (errorMessage, showError, isLoading)
    // MARK: - Dependencies
    private var repository: FooRepository?
    // MARK: - Setup
    func setup(modelContext: ModelContext) { ... }
    // MARK: - Actions
}
```

The view holds it as `@State private var viewModel = FooViewModel()` and calls `viewModel.setup(modelContext: modelContext)` in `.onAppear`. Mark state read-only via `private(set)`. Errors from repositories surface through `errorMessage` + `showError` and an `.alert` modifier on the view.

**Inconsistency to be aware of:** some views (e.g. `RecipeView`) use both `@Query` AND a ViewModel — `@Query` drives the live list while the ViewModel handles mutating actions (favorite, duplicate, delete). Other views go through the repository only. When editing, match the surrounding file's style rather than enforcing one approach.

### Settings & locking

`AppSettings.shared` is a singleton `@Observable` persisted via `UserDefaults`. It owns `theme` (system/light/dark), `language` (en/th — switching writes `AppleLanguages`), and the recipe edit lock (`isRecipeEditLocked` + `recipePin`). The `.recipeEditLocked(hide: true)` view modifier (in `Core/Extension/View+Permission.swift`) hides edit affordances when the lock is on.

### Localization

Strings live in `DailyJolly/Resources/{en,th}.lproj/Localizable.strings`. Use `String(localized: "...")` in Swift code and `NSLocalizedString` in enum extensions (see `InventoryUnit.displayName`). Add new strings to **both** `.strings` files.
