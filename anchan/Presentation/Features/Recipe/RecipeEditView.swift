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
    var unit: InventoryUnit
    var note: String
}

// MARK: - Recipe Edit View

struct RecipeEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier?

    @State private var recipe: RecipeEntity?
    @State private var name: String = ""
    @State private var note: String = ""
    @State private var category: String = ""
    @State private var steps: [StepInput] = []
    @State private var ingredients: [IngredientInput] = []
    @State private var isAddingStep: Bool = false
    @State private var isAddingIngredient: Bool = false
    @State private var showDeleteAlert: Bool = false

    private var isEditing: Bool { id != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var totalTime: Int {
        steps.reduce(0) { $0 + $1.time }
    }

    private var totalCost: Double {
        ingredients.reduce(0.0) { total, ingredient in
            if let inventory = modelContext.model(for: ingredient.inventoryId) as? InventoryEntity {
                let quantityInBaseUnit = ingredient.unit.convert(ingredient.quantity, to: inventory.baseUnit) ?? ingredient.quantity
                return total + (quantityInBaseUnit * inventory.unitPrice)
            }
            return total
        }
    }

    var body: some View {
        Form {
            basicInfoSection
            ingredientsSection
            stepsSection

            if isEditing {
                deleteSection
            }
        }
        .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
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
                    saveRecipe()
                }
                .fontWeight(.semibold)
                .disabled(!canSave)
            }
        }
        .sheet(isPresented: $isAddingStep) {
            AddStepSheet { newStep in
                steps.append(newStep)
            }
        }
        .sheet(isPresented: $isAddingIngredient) {
            AddIngredientSheet { newIngredient in
                ingredients.append(newIngredient)
            }
        }
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
        .onAppear {
            loadRecipe()
        }
    }

    // MARK: - Sections

    private var basicInfoSection: some View {
        Section {
            TextField("Recipe Name", text: $name)
                .textInputAutocapitalization(.words)

            TextField("Category (optional)", text: $category)
                .textInputAutocapitalization(.words)

            TextField("Notes (optional)", text: $note, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Basic Info")
        }
    }

    private var ingredientsSection: some View {
        Section {
            if ingredients.isEmpty {
                Text("No ingredients added")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(ingredients.indices, id: \.self) { index in
                    IngredientRowView(ingredient: ingredients[index]) {
                        ingredients.remove(at: index)
                    }
                }

                if totalCost > 0 {
                    HStack {
                        Text("Estimated Cost")
                            .fontWeight(.medium)
                        Spacer()
                        Text("฿\(totalCost.clean)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                isAddingIngredient = true
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Ingredients")
        }
    }

    private var stepsSection: some View {
        Section {
            if steps.isEmpty {
                Text("No steps added")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(steps.indices, id: \.self) { index in
                    StepRowView(step: steps[index]) {
                        steps.remove(at: index)
                    }
                }
                .onMove { from, to in
                    steps.move(fromOffsets: from, toOffset: to)
                }

                if totalTime > 0 {
                    HStack {
                        Text("Total Time")
                            .fontWeight(.medium)
                        Spacer()
                        Text(totalTime.formattedTime)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                isAddingStep = true
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
                showDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Recipe")
                    Spacer()
                }
            }
        }
    }

    // MARK: - Actions

    private func loadRecipe() {
        guard let id else { return }
        recipe = modelContext.model(for: id) as? RecipeEntity

        guard let recipe else { return }
        name = recipe.name
        note = recipe.note
        category = recipe.category ?? ""
        steps = recipe.sortedSteps.map { step in
            StepInput(title: step.title, note: step.note, time: step.time)
        }
        ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(
                inventoryId: ingredient.inventoryItem.persistentModelID,
                inventoryName: ingredient.inventoryItem.name,
                quantity: ingredient.quantity,
                unit: ingredient.unit,
                note: ingredient.note ?? ""
            )
        }
    }

    private func saveRecipe() {
        if let recipe {
            // Update existing
            recipe.name = name.trimmingCharacters(in: .whitespaces)
            recipe.note = note
            recipe.category = category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)

            // Remove old steps
            for step in recipe.steps {
                modelContext.delete(step)
            }
            recipe.steps.removeAll()

            // Remove old ingredients
            for ingredient in recipe.ingredients {
                modelContext.delete(ingredient)
            }
            recipe.ingredients.removeAll()

            // Add new steps
            for (index, stepInput) in steps.enumerated() {
                let step = RecipeStepEntity(
                    title: stepInput.title,
                    note: stepInput.note,
                    time: stepInput.time,
                    order: index
                )
                step.recipe = recipe
                recipe.steps.append(step)
            }

            // Add new ingredients
            for ingredientInput in ingredients {
                if let inventory = modelContext.model(for: ingredientInput.inventoryId) as? InventoryEntity {
                    let ingredient = IngredientEntity(
                        inventoryItem: inventory,
                        quantity: ingredientInput.quantity,
                        unit: ingredientInput.unit,
                        note: ingredientInput.note.isEmpty ? nil : ingredientInput.note,
                        recipe: recipe
                    )
                    recipe.ingredients.append(ingredient)
                }
            }
        } else {
            // Create new
            let newRecipe = RecipeEntity(
                name: name.trimmingCharacters(in: .whitespaces),
                note: note,
                category: category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)
            )

            for (index, stepInput) in steps.enumerated() {
                let step = RecipeStepEntity(
                    title: stepInput.title,
                    note: stepInput.note,
                    time: stepInput.time,
                    order: index
                )
                step.recipe = newRecipe
                newRecipe.steps.append(step)
            }

            // Add ingredients to new recipe
            for ingredientInput in ingredients {
                if let inventory = modelContext.model(for: ingredientInput.inventoryId) as? InventoryEntity {
                    let ingredient = IngredientEntity(
                        inventoryItem: inventory,
                        quantity: ingredientInput.quantity,
                        unit: ingredientInput.unit,
                        note: ingredientInput.note.isEmpty ? nil : ingredientInput.note,
                        recipe: newRecipe
                    )
                    newRecipe.ingredients.append(ingredient)
                }
            }

            modelContext.insert(newRecipe)
        }

        stackRouter.pop()
    }

    private func deleteRecipe() {
        if let recipe {
            modelContext.delete(recipe)
        }
        // Pop twice to go back past detail view
        stackRouter.popToRoot()
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

                Text("\(ingredient.quantity.clean) \(ingredient.unit.symbol)")
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

    @State private var inventoryItems: [InventoryEntity] = []
    @State private var selectedInventory: InventoryEntity?
    @State private var quantity: Double = 1
    @State private var unit: InventoryUnit = .g
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
                                unit = inventory.baseUnit
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

                        Picker("Unit", selection: $unit) {
                            ForEach(InventoryUnit.allCases) { unitOption in
                                Text(unitOption.displayName).tag(unitOption)
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
                                unit: unit,
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
