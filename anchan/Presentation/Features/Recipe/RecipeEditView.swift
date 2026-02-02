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
        .navigationTitle(viewModel.isEditing ? "Edit Recipe" : "New Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    stackRouter.pop()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
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
        .alert("Delete Recipe", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteRecipe {
                    stackRouter.popToRoot()
                }
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, recipeId: id)
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section {
            TextField("Recipe Name", text: $viewModel.name)
                .textInputAutocapitalization(.words)

            TextField("Category (optional)", text: $viewModel.category)
                .textInputAutocapitalization(.words)

            TextField("Notes (optional)", text: $viewModel.note, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Basic Info")
        }
    }

    private var batchSection: some View {
        Section {
            Stepper("Batch Size: \(viewModel.batchSize)", value: $viewModel.batchSize, in: 1...1000)

            TextField("Unit (e.g., pcs, bottles)", text: $viewModel.batchUnit)
                .textInputAutocapitalization(.never)

            if viewModel.totalCost > 0 && viewModel.batchSize > 0 {
                HStack {
                    Text("Cost per \(viewModel.batchUnit)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("฿\((viewModel.totalCost / Double(viewModel.batchSize)).clean)")
                        .fontWeight(.medium)
                }
            }
        } header: {
            Text("Batch Output")
        } footer: {
            Text("How many units does one batch of this recipe produce?")
        }
    }

    private var ingredientsSection: some View {
        Section {
            if viewModel.ingredients.isEmpty {
                Text("No ingredients added")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.ingredients.indices, id: \.self) { index in
                    IngredientRowView(ingredient: viewModel.ingredients[index]) {
                        viewModel.removeIngredient(at: index)
                    }
                }

                if viewModel.totalCost > 0 {
                    HStack {
                        Text("Estimated Cost")
                            .fontWeight(.medium)
                        Spacer()
                        Text("฿\(viewModel.totalCost.clean)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                viewModel.isAddingIngredient = true
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Ingredients")
        }
    }

    private var stepsSection: some View {
        Section {
            if viewModel.steps.isEmpty {
                Text("No steps added")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.steps.indices, id: \.self) { index in
                    StepRowView(step: viewModel.steps[index]) {
                        viewModel.removeStep(at: index)
                    }
                }
                .onMove { from, to in
                    viewModel.moveSteps(from: from, to: to)
                }

                if viewModel.totalTime > 0 {
                    HStack {
                        Text("Total Time")
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
                Label("Add Step", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Steps")
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Recipe")
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

                Text("\(ingredient.quantity.clean) \(ingredient.unitSymbol.uppercased())")
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
                        Text("No inventory items available")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Item", selection: $selectedInventory) {
                            Text("Select an item").tag(nil as InventoryEntity?)
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
                    Text("Inventory Item")
                }

                if selectedInventory != nil {
                    Section {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            TextField("Amount", value: $quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                        Picker("Unit", selection: $unitSymbol) {
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
                        Text("Amount")
                    }

                    Section {
                        TextField("Note (optional)", text: $note, axis: .vertical)
                            .lineLimit(2...3)
                    } header: {
                        Text("Additional Info")
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
                    TextField("Step Title", text: $title)
                        .textInputAutocapitalization(.words)

                    TextField("Description (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Step Info")
                }

                Section {
                    TimePickerView(title: "Duration", minutes: $time)
                } header: {
                    Text("Time")
                }
            }
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
