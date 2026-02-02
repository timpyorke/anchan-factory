import SwiftUI
import SwiftData

// MARK: - Step Input Model

struct StepInput: Identifiable {
    let id = UUID()
    var title: String
    var note: String
    var time: Int
}

// MARK: - Ingredient Input Model

struct IngredientInput: Identifiable {
    let id = UUID()
    var inventoryId: PersistentIdentifier
    var inventoryName: String
    var quantity: Double
    var unitSymbol: String
    var note: String
}

// MARK: - Recipe Edit View

struct RecipeEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier?

    @State private var viewModel = RecipeEditViewModel()

    var body: some View {
        Form {
            basicInfoSection
            batchSection
            ingredientsSection
            stepsSection

            if viewModel.isEditing {
                deleteSection
            }
        }
        .navigationTitle(viewModel.isEditing ? String(localized: "Edit Recipe") : String(localized: "New Recipe"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Cancel")) {
                    stackRouter.pop()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save")) {
                    viewModel.saveRecipe {
                        stackRouter.pop()
                    }
                }
                .fontWeight(.semibold)
                .disabled(!viewModel.canSave)
            }
        }
        .sheet(isPresented: $viewModel.isAddingStep) {
            AddStepSheet { newStep in
                viewModel.addStep(newStep)
            }
        }
        .sheet(isPresented: $viewModel.isAddingIngredient) {
            AddIngredientSheet { newIngredient in
                viewModel.addIngredient(newIngredient)
            }
        }
        .alert(String(localized: "Delete Recipe"), isPresented: $viewModel.showDeleteAlert) {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button(String(localized: "Delete"), role: .destructive) {
                viewModel.deleteRecipe {
                    stackRouter.popToRoot()
                }
            }
        } message: {
            Text(String(localized: "Are you sure you want to delete this recipe? This action cannot be undone."))
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, recipeId: id)
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section {
            TextField(String(localized: "Recipe Name"), text: $viewModel.name)
                .textInputAutocapitalization(.words)

            TextField(String(localized: "Category (optional)"), text: $viewModel.category)
                .textInputAutocapitalization(.words)

            TextField(String(localized: "Notes (optional)"), text: $viewModel.note, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text(String(localized: "Basic Info"))
        }
    }

    private var batchSection: some View {
        Section {
            Stepper(String(localized: "Batch Size") + ": \(viewModel.batchSize)", value: $viewModel.batchSize, in: 1...1000)

            TextField(String(localized: "Unit (e.g., pcs, bottles)"), text: $viewModel.batchUnit)
                .textInputAutocapitalization(.never)

            if viewModel.totalCost > 0 && viewModel.batchSize > 0 {
                HStack {
                    Text(String(localized: "Cost per \(viewModel.batchUnit)"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(CurrencyFormatter.format(viewModel.totalCost / Double(viewModel.batchSize)))
                        .fontWeight(.medium)
                }
            }
        } header: {
            Text(String(localized: "Batch Output"))
        } footer: {
            Text(String(localized: "How many units does one batch of this recipe produce?"))
        }
    }

    private var ingredientsSection: some View {
        Section {
            if viewModel.ingredients.isEmpty {
                Text(String(localized: "No ingredients added"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.ingredients) { ingredient in
                    IngredientRowView(ingredient: ingredient) {
                        viewModel.removeIngredient(ingredient)
                    }
                }

                if viewModel.totalCost > 0 {
                    HStack {
                        Text(String(localized: "Estimated Cost"))
                            .fontWeight(.medium)
                        Spacer()
                        Text(CurrencyFormatter.format(viewModel.totalCost))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                viewModel.isAddingIngredient = true
            } label: {
                Label(String(localized: "Add Ingredient"), systemImage: "plus.circle.fill")
            }
        } header: {
            Text(String(localized: "Ingredients"))
        }
    }

    private var stepsSection: some View {
        Section {
            if viewModel.steps.isEmpty {
                Text(String(localized: "No steps added"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.steps) { step in
                    StepRowView(step: step) {
                        viewModel.removeStep(step)
                    }
                }
                .onMove { from, to in
                    viewModel.moveSteps(from: from, to: to)
                }

                if viewModel.totalTime > 0 {
                    HStack {
                        Text(String(localized: "Total Time"))
                            .fontWeight(.medium)
                        Spacer()
                        Text(viewModel.totalTime.formattedTime)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                viewModel.isAddingStep = true
            } label: {
                Label(String(localized: "Add Step"), systemImage: "plus.circle.fill")
            }
        } header: {
            Text(String(localized: "Steps"))
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text(String(localized: "Delete Recipe"))
                    Spacer()
                }
            }
        }
    }

}

// MARK: - Step Row View

private struct StepRowView: View {
    let step: StepInput
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)

                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if step.time > 0 {
                    Label(step.time.formattedTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Ingredient Row View

private struct IngredientRowView: View {
    let ingredient: IngredientInput
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.inventoryName)
                    .font(.headline)

                Text("\(AppNumberFormatter.format(ingredient.quantity)) \(ingredient.unitSymbol.uppercased())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !ingredient.note.isEmpty {
                    Text(ingredient.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Ingredient Sheet

private struct AddIngredientSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CustomUnitEntity.name)
    private var customUnits: [CustomUnitEntity]

    @State private var inventoryItems: [InventoryEntity] = []
    @State private var selectedInventory: InventoryEntity?
    @State private var quantity: Double = 1
    @State private var unitSymbol: String = "g"
    @State private var note: String = ""
    @State private var searchText: String = ""

    let onAdd: (IngredientInput) -> Void

    private var canAdd: Bool {
        selectedInventory != nil && quantity > 0
    }

    private var filteredItems: [InventoryEntity] {
        if searchText.isEmpty {
            return inventoryItems
        }
        return inventoryItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if inventoryItems.isEmpty {
                        Text(String(localized: "No inventory items available"))
                            .foregroundStyle(.secondary)
                    } else {
                        Picker(String(localized: "Select Item"), selection: $selectedInventory) {
                            Text(String(localized: "Select an item")).tag(nil as InventoryEntity?)
                            ForEach(filteredItems, id: \.persistentModelID) { item in
                                Text(item.name).tag(item as InventoryEntity?)
                            }
                        }
                        .onChange(of: selectedInventory) { _, newValue in
                            if let inventory = newValue {
                                unitSymbol = inventory.unitSymbol
                            }
                        }
                    }
                } header: {
                    Text(String(localized: "Inventory Item"))
                }

                if selectedInventory != nil {
                    Section {
                        HStack {
                            Text(String(localized: "Quantity"))
                            Spacer()
                            TextField(String(localized: "Amount"), value: $quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                        Picker(String(localized: "Unit"), selection: $unitSymbol) {
                            ForEach(InventoryUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit.rawValue)
                            }

                            if !customUnits.isEmpty {
                                Divider()
                                ForEach(customUnits, id: \.persistentModelID) { unit in
                                    Text("\(unit.name) (\(unit.symbol.uppercased()))").tag(unit.symbol)
                                }
                            }
                        }
                    } header: {
                        Text(String(localized: "Amount"))
                    }

                    Section {
                        TextField(String(localized: "Note (optional)"), text: $note, axis: .vertical)
                            .lineLimit(2...3)
                    } header: {
                        Text(String(localized: "Additional Info"))
                    }
                }
            }
            .navigationTitle(String(localized: "Add Ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        if let inventory = selectedInventory {
                            let ingredient = IngredientInput(
                                inventoryId: inventory.persistentModelID,
                                inventoryName: inventory.name,
                                quantity: quantity,
                                unitSymbol: unitSymbol,
                                note: note
                            )
                            onAdd(ingredient)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!canAdd)
                }
            }
            .onAppear {
                loadInventoryItems()
            }
        }
    }

    private func loadInventoryItems() {
        let descriptor = FetchDescriptor<InventoryEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        inventoryItems = (try? modelContext.fetch(descriptor)) ?? []
    }
}

// MARK: - Add Step Sheet

private struct AddStepSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var time: Int = 0

    let onAdd: (StepInput) -> Void

    private var canAdd: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Step Title"), text: $title)
                        .textInputAutocapitalization(.words)

                    TextField(String(localized: "Description (optional)"), text: $note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text(String(localized: "Step Info"))
                }

                Section {
                    TimePickerView(title: String(localized: "Duration"), minutes: $time)
                } header: {
                    Text(String(localized: "Time"))
                }
            }
            .navigationTitle(String(localized: "Add Step"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        let step = StepInput(
                            title: title.trimmingCharacters(in: .whitespaces),
                            note: note,
                            time: time
                        )
                        onAdd(step)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canAdd)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeEditView(id: nil)
    }
    .environment(StackRouter())
    .modelContainer(AppModelContainer.make())
}
