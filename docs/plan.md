# Development Plan: Daily Jolly Enhancement

This document outlines the implementation strategy for the new production and quality control requirements.

## 1. Overview of Requirements
- **Flexible Output:** Ability to override the expected production quantity during manufacturing.
- **Parallel Production Lines:** Support for "branch and merge" workflows (multiple lines combined into one).
- **Integrated Quality Control (QC):**
    - **Raw Materials:** pH tracking for inventory items.
    - **Process Steps:** Measurement logging for Temp, pH, Brix, and Aw.
    - **Reporting:** Database-ready reports for all QC measurements.
- **Production Templates:** 5 core patterns based on gelling agents.
- **Analytics Dashboard:** Process compliance and batch-to-batch variance analysis.

---

## 2. Data Model Changes (SwiftData)

### Inventory & Ingredients
- **`InventoryEntity`**: Add `phValue: Double?` and `lastUpdated: Date`.
- **`IngredientEntity`**: Add `batchPhValue: Double?` (to capture the pH of the specific material used in a batch).

### Recipe & Steps
- **`RecipeStepEntity`**: 
    - `lineIdentifier: String?` (e.g., "Line A", "Line B").
    - `dependencies: [RecipeStepEntity]` (for merging points).
    - `requiredMeasurements: [MeasurementType]` (Enum: `temp`, `ph`, `brix`, `aw`).
- **`RecipeEntity`**:
    - `templateType: GellingAgentType` (Enum for the 5 types).

### Manufacturing & Results
- **`ManufacturingEntity`**:
    - `actualOutput: Double?`.
    - `complianceScore: Double`.
- **`MeasurementLog` (New Entity)**:
    - `type: MeasurementType`.
    - `value: Double`.
    - `step: RecipeStepEntity`.
    - `batch: ManufacturingEntity`.
    - `timestamp: Date`.

---

## 3. Implementation Phases

### Phase 1: Quality Control Infrastructure
- Update `InventoryAddView` and `InventoryDetailView` to include pH tracking.
- Enhance the Recipe Builder to allow users to toggle required measurements (Temp, pH, Brix, Aw) for each step.
- Update `CSVExportService` to include separate sheets/sections for pH database and step measurements.

### Phase 2: Parallel Workflow & Templates
- Refactor the manufacturing execution logic to support non-linear progress (Parallel Lines).
- Implement a "Merge Point" check: Steps that require completion of multiple previous steps.
- Create the 5 "Gelling Agent" templates that auto-populate step structures.

### Phase 3: Manufacturing UI Update
- Add real-time measurement input fields during the production process.
- Implement validation: Ensure required measurements are logged before a step can be marked "Complete".
- Allow overriding the "Total Units" produced at the final step.

### Phase 4: Analytics & Dashboard
- Create a new "Summary Report" view.
- **Compliance Tracking:** Percentage of steps completed correctly with all QC data.
- **Variance Analysis:** Compare pH/Brix values across multiple batches of the same recipe to identify inconsistency.

---

## 4. Technical Considerations
- **UI Complexity:** Managing parallel lines on iPad will require a split-view or a "Line Selector" within the manufacturing screen.
- **Data Integrity:** Ensure that if a raw material pH is updated, it doesn't retroactively change historical batch data (Snapshotted pH).
- **Offline Support:** All measurements must be stored locally in SwiftData first.

---

## 5. Next Steps
1. **Research:** Analyze the "Sample Case" from the user for specific QC standards.
2. **Strategy:** Finalize the "Branch and Merge" UI design (Diagramming the flow).
3. **Execution:** Start with Data Model migration.
