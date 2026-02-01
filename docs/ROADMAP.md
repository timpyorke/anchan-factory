# Anchan Factory - 30 Day Roadmap

## Overview

This roadmap outlines the development plan for the Recipe feature over 30 days, tracked weekly.

## Current Status

- [x] Project setup and architecture
- [x] Navigation system (TabRouter, StackRouter)
- [x] SwiftData configuration
- [x] Inventory feature (CRUD with edit mode)
- [ ] Recipe feature

---

## Week 1: Recipe Foundation (Days 1-7)

### Goals
Establish the core Recipe data layer and basic UI.

### Tasks

| Day | Task | Status |
|-----|------|--------|
| 1 | Create `RecipeRepository` with CRUD operations | ⬜ |
| 1 | Update `RecipeEntity` with full properties (servings, prepTime, cookTime, instructions) | ⬜ |
| 2 | Create `RecipeView` with list display | ⬜ |
| 2 | Create `RecipeViewModel` connected to repository | ⬜ |
| 3 | Create `AddRecipeView` for new recipes | ⬜ |
| 3 | Implement empty state for Recipe list | ⬜ |
| 4 | Add AppBarView to RecipeView with add button | ⬜ |
| 4 | Implement search functionality | ⬜ |
| 5 | Create `RecipeDetailView` to display full recipe | ⬜ |
| 5 | Connect detail view with navigation (StackRouter) | ⬜ |
| 6-7 | Testing and bug fixes | ⬜ |

### Deliverables
- Recipe list view with search
- Add new recipe functionality
- Recipe detail view
- Basic CRUD operations

---

## Week 2: Ingredients Integration (Days 8-14)

### Goals
Connect recipes with inventory ingredients.

### Tasks

| Day | Task | Status |
|-----|------|--------|
| 8 | Create `IngredientRepository` for ingredient operations | ⬜ |
| 8 | Design ingredient picker UI component | ⬜ |
| 9 | Implement ingredient list in AddRecipeView | ⬜ |
| 9 | Create `AddIngredientView` sheet | ⬜ |
| 10 | Inventory item picker (search and select from InventoryEntity) | ⬜ |
| 10 | Quantity and unit input for ingredients | ⬜ |
| 11 | Display ingredients in RecipeDetailView | ⬜ |
| 11 | Edit ingredients in existing recipe | ⬜ |
| 12 | Delete ingredient from recipe | ⬜ |
| 12 | Reorder ingredients (drag and drop) | ⬜ |
| 13-14 | Testing and bug fixes | ⬜ |

### Deliverables
- Add ingredients to recipes
- Select from inventory items
- Edit/delete ingredients
- Ingredient list display

---

## Week 3: Recipe Enhancements (Days 15-21)

### Goals
Add advanced recipe features and improve UX.

### Tasks

| Day | Task | Status |
|-----|------|--------|
| 15 | Recipe edit mode (update existing recipes) | ⬜ |
| 15 | Delete recipe with confirmation | ⬜ |
| 16 | Recipe categories/tags | ⬜ |
| 16 | Filter recipes by category | ⬜ |
| 17 | Recipe notes field | ⬜ |
| 17 | Prep time and cook time display | ⬜ |
| 18 | Servings adjuster (scale ingredients) | ⬜ |
| 18 | Calculate total cost from ingredients | ⬜ |
| 19 | Recipe duplication feature | ⬜ |
| 19 | Favorite/bookmark recipes | ⬜ |
| 20-21 | Testing and bug fixes | ⬜ |

### Deliverables
- Full recipe editing
- Categories and filtering
- Cost calculation
- Recipe scaling

---

## Week 4: Polish & Home Dashboard (Days 22-30)

### Goals
Integrate features into Home dashboard and polish the app.

### Tasks

| Day | Task | Status |
|-----|------|--------|
| 22 | Home dashboard design | ⬜ |
| 22 | Display recent recipes on Home | ⬜ |
| 23 | Quick stats (total recipes, total inventory items) | ⬜ |
| 23 | Low stock inventory alerts | ⬜ |
| 24 | Quick actions on Home (add recipe, add inventory) | ⬜ |
| 24 | Search across recipes and inventory | ⬜ |
| 25 | Settings page improvements | ⬜ |
| 25 | Dark mode support verification | ⬜ |
| 26 | UI polish and consistency | ⬜ |
| 26 | Loading states and animations | ⬜ |
| 27 | Error handling improvements | ⬜ |
| 27 | Empty states for all screens | ⬜ |
| 28-30 | Final testing and bug fixes | ⬜ |

### Deliverables
- Functional Home dashboard
- Cross-feature integration
- Polished UI/UX
- Stable release candidate

---

## Feature Summary

### Recipe Feature Components

```
Recipe/
├── RecipeView.swift              # List view
├── RecipeViewModel.swift         # List logic
├── RecipeDetailView.swift        # Detail view
├── RecipeDetailViewModel.swift   # Detail logic
├── AddRecipeView.swift           # Create/Edit form
└── Components/
    ├── RecipeRowView.swift       # List row
    ├── IngredientPickerView.swift
    └── IngredientRowView.swift
```

### Data Models

```swift
// RecipeEntity (existing, to be enhanced)
@Model class RecipeEntity {
    var name: String
    var note: String
    var instructions: String?
    var servings: Int
    var prepTime: Int?        // minutes
    var cookTime: Int?        // minutes
    var category: String?
    var isFavorite: Bool
    var createdAt: Date
    var ingredients: [IngredientEntity]
}

// IngredientEntity (existing)
@Model class IngredientEntity {
    var quantity: Double
    var unit: InventoryUnit
    var note: String?
    var inventoryItem: InventoryEntity
    var recipe: RecipeEntity
}
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Recipe CRUD | Fully functional |
| Ingredient linking | Recipes use inventory items |
| Cost calculation | Accurate based on unit prices |
| Search | Works across recipes |
| Navigation | Smooth between all screens |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| SwiftData relationship issues | Test early, keep relationships simple |
| UI complexity | Start with minimal UI, iterate |
| Scope creep | Stick to weekly goals |
| Data migration | Version schema from start |

---

## Next Steps

1. Start Week 1 tasks
2. Create `RecipeRepository`
3. Update `RecipeEntity` with full properties
4. Build `RecipeView` with basic list

---

*Last updated: 2026-02-01*
