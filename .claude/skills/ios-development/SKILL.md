---
name: ios-development
description: Guides modern iOS app development with SwiftUI. Use when building iOS apps, implementing SwiftUI views, managing state, or when the user asks about iOS/SwiftUI best practices.
---

When developing modern iOS applications with SwiftUI, always follow these practices:

1. **Use SwiftUI-First Architecture**:
   - Prefer **MVVM** with `@Observable` (iOS 17+) or `ObservableObject`
   - Use **Swift Data** for persistence (replaces Core Data)
   - Leverage **Swift Concurrency** (`async/await`, actors) over Combine

2. **Modern State Management**:
   - `@State` → Local view state
   - `@Binding` → Two-way connection to parent state
   - `@Observable` → Modern observation (iOS 17+)
   - `@Environment` → Dependency injection via environment
   - `@Query` → Swift Data fetching

3. **SwiftUI View Composition**:
   - Extract reusable views as separate structs
   - Use `ViewModifier` for reusable styling
   - Prefer `@ViewBuilder` for conditional content
   - Use `PreviewProvider` / `#Preview` macro for live previews

4. **Navigation & Routing**:
   - Use `NavigationStack` with `.navigationDestination(for:)`
   - Implement type-safe navigation with enums
   - Manage navigation state in ViewModel for deep linking

5. **Modern Concurrency**:
   - Use `.task { }` modifier for async work on view appear
   - Leverage `@MainActor` for UI updates
   - Use `TaskGroup` for parallel operations

6. **Accessibility & Localization**:
   - Add `.accessibilityLabel()` and `.accessibilityHint()`
   - Use `String(localized:)` for all user-facing text
   - Support Dynamic Type with built-in text styles

7. **Testing Strategy**:
   - Unit test ViewModels with Swift Testing framework
   - Use `@Testable import` for internal access
   - Mock dependencies with protocols

**Gotcha**: When using `@Observable`, don't wrap properties in `@Published`—observation is automatic!
