# Anchan Factory - Development Roadmap

## Overview

This document tracks the development progress and future plans for Anchan Factory.

## Completed Features

### Core Infrastructure
- [x] Project setup and architecture (MVVM)
- [x] Navigation system (TabRouter, StackRouter)
- [x] SwiftData configuration with all entities
- [x] Repository pattern implementation
- [x] Error handling with AppError enum
- [x] Settings persistence (theme, language)
- [x] Localization (English, Thai)

### Recipe Management
- [x] RecipeEntity with full properties
- [x] RecipeRepository with CRUD operations
- [x] RecipeView with list and search
- [x] RecipeDetailView with full display
- [x] RecipeEditView for create/edit
- [x] Recipe ingredients with inventory linking
- [x] Recipe steps with time tracking
- [x] Batch size and output unit
- [x] Cost calculation (total and per-unit)
- [x] Favorite recipes
- [x] Categories support

### Inventory Management
- [x] InventoryEntity with stock tracking
- [x] InventoryRepository with CRUD
- [x] InventoryView with list and search
- [x] InventoryAddView for create/edit
- [x] Unit price tracking
- [x] Minimum stock thresholds
- [x] Low stock indicators
- [x] Built-in units (g, kg, ml, l, pcs)
- [x] Custom units support

### Manufacturing Management
- [x] ManufacturingEntity with status tracking
- [x] ManufacturingRepository with CRUD
- [x] ManufacturingView for in-progress tracking
- [x] ManufacturingDetailView for completed batches
- [x] Auto batch number generation (YYMMDD-XXX)
- [x] Step-by-step progress tracking
- [x] Step completion timestamps
- [x] Automatic inventory deduction on completion
- [x] Manufacturing cost calculation

### Dashboard (Home)
- [x] Summary statistics cards
- [x] Active manufacturing display
- [x] Recently completed batches
- [x] Low stock alerts
- [x] Quick action: start new manufacturing

### Settings
- [x] Theme selection (System/Light/Dark)
- [x] Language selection (English/Thai)
- [x] Custom units management
- [x] Data export to CSV
- [x] Clear all data option

### Data Export
- [x] CSVExportService implementation
- [x] Export individual manufacturing
- [x] Export all manufacturing batches
- [x] Export inventory list
- [x] Export recipes

---

## Current Status

**Version:** 1.0 (Development)

**Recent Updates:**
- Inventory deduction on manufacturing completion
- Dashboard enhancements
- Silent error handling for initial data load
- Deprecation warnings cleanup
- View layer formatters implementation

---

## Planned Features

### Phase 1: Polish & Stability

| Feature | Priority | Status |
|---------|----------|--------|
| Comprehensive unit testing | High | Planned |
| UI/UX refinements | Medium | Planned |
| Performance optimization | Medium | Planned |
| Edge case handling | High | Planned |

### Phase 2: Enhanced Features

| Feature | Priority | Status |
|---------|----------|--------|
| Recipe duplication | Medium | Planned |
| Recipe scaling (adjust servings) | Medium | Planned |
| Manufacturing pause/resume | Low | Planned |
| Batch manufacturing (multiple recipes) | Low | Planned |
| Inventory restock suggestions | Medium | Planned |

### Phase 3: Analytics & Reporting

| Feature | Priority | Status |
|---------|----------|--------|
| Manufacturing history charts | Medium | Planned |
| Cost analysis reports | Medium | Planned |
| Inventory usage trends | Low | Planned |
| Production efficiency metrics | Low | Planned |

### Phase 4: Advanced Features

| Feature | Priority | Status |
|---------|----------|--------|
| Cloud sync (iCloud) | Low | Planned |
| Multiple user support | Low | Planned |
| Barcode scanning for inventory | Low | Planned |
| Recipe import/export | Medium | Planned |
| Image support for recipes | Low | Planned |

---

## Technical Debt

| Item | Priority | Notes |
|------|----------|-------|
| Add comprehensive unit tests | High | Cover ViewModels and Repositories |
| UI accessibility improvements | Medium | VoiceOver support |
| Performance profiling | Medium | Large data sets |
| Code documentation | Low | Add inline comments |

---

## Architecture Summary

```
┌─────────────────────────────────────────┐
│            Presentation Layer           │
│  ┌─────────────────────────────────┐   │
│  │ Views (SwiftUI)                 │   │
│  │ ViewModels (@Observable)        │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│              Core Layer                 │
│  Navigation │ Database │ Formatters    │
│  Settings   │ Utilities│ Extensions    │
├─────────────────────────────────────────┤
│              Data Layer                 │
│  Entities (SwiftData @Model)           │
│  Repositories (CRUD + Result type)     │
│  Services (CSVExportService)           │
└─────────────────────────────────────────┘
```

---

## Entity Summary

| Entity | Purpose | Relationships |
|--------|---------|---------------|
| RecipeEntity | Recipe definition | → Ingredients, Steps |
| RecipeStepEntity | Production step | ← Recipe |
| IngredientEntity | Recipe ingredient | ← Recipe, → Inventory |
| InventoryEntity | Stock item | ← Ingredients |
| ManufacturingEntity | Production batch | → Recipe |
| CustomUnitEntity | User-defined unit | Standalone |

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Recipe CRUD | Fully functional | ✅ Complete |
| Inventory management | Fully functional | ✅ Complete |
| Manufacturing workflow | Fully functional | ✅ Complete |
| Cost calculation | Accurate | ✅ Complete |
| Inventory deduction | Automatic | ✅ Complete |
| Data export | CSV format | ✅ Complete |
| Navigation | Smooth | ✅ Complete |
| Error handling | User-friendly | ✅ Complete |

---

## Contributing

When adding new features:

1. Follow MVVM architecture
2. Use Repository pattern for data access
3. Return `Result<T, AppError>` from repositories
4. Add `@MainActor` to ViewModels
5. Use `@Observable` for reactive state
6. Support localization with `String(localized:)`
7. Update documentation

---

*Last updated: 2026-02-02*
