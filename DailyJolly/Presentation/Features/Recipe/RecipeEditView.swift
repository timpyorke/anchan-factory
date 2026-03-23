import SwiftUI
import SwiftData

// MARK: - Step Input Model

struct StepInput: Identifiable {
    var id: UUID = UUID()
    var title: String
    var note: String
    var time: Int
    var isTimerRequired: Bool = false
    var requiredMeasurements: [MeasurementType] = []
    var lineIdentifier: String?
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
    @State private var editingStep: StepInput?

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
                .recipeEditLocked(hide: false, showIcon: true)
            }
        }
        .sheet(isPresented: $viewModel.isAddingStep) {
            StepEditSheet { newStep in
                viewModel.addStep(newStep)
            }
        }
        .sheet(item: $editingStep) { step in
            StepEditSheet(step: step) { updatedStep in
                viewModel.updateStep(updatedStep)
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
                .disabled(AppSettings.shared.isRecipeEditLocked)

            TextField(String(localized: "Category (optional)"), text: $viewModel.category)
                .textInputAutocapitalization(.words)
                .disabled(AppSettings.shared.isRecipeEditLocked)

            TextField(String(localized: "Notes (optional)"), text: $viewModel.note, axis: .vertical)
                .lineLimit(2...4)
                .disabled(AppSettings.shared.isRecipeEditLocked)

            Picker(String(localized: "Gelling Agent Template"), selection: $viewModel.templateType) {
                Text(String(localized: "None")).tag(nil as GellingAgentType?)
                ForEach(GellingAgentType.allCases) { type in
                    VStack(alignment: .leading) {
                        Text(type.rawValue)
                        Text(type.description).font(.caption).foregroundStyle(.secondary)
                    }.tag(type as GellingAgentType?)
                }
            }
            .disabled(AppSettings.shared.isRecipeEditLocked)
            .onChange(of: viewModel.templateType) { _, newValue in
                if let template = newValue {
                    viewModel.applyTemplate(template)
                }
            }
        } header: {
            Text(String(localized: "Basic Info"))
        }
    }

    private var batchSection: some View {
        Section {
            Stepper(String(localized: "Batch Size") + ": \(viewModel.batchSize)", value: $viewModel.batchSize, in: 1...1000)
                .disabled(AppSettings.shared.isRecipeEditLocked)

            TextField(String(localized: "Unit (e.g., pcs, bottles)"), text: $viewModel.batchUnit)
                .textInputAutocapitalization(.never)
                .disabled(AppSettings.shared.isRecipeEditLocked)

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
                    .disabled(AppSettings.shared.isRecipeEditLocked)
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
            .recipeEditLocked(hide: true)
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
                    HStack {
                        StepRowView(step: step)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !AppSettings.shared.isRecipeEditLocked {
                                    editingStep = step
                                }
                            }

                        if !AppSettings.shared.isRecipeEditLocked {
                            Button(role: .destructive) {
                                viewModel.removeStep(step)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .onMove { from, to in
                    if !AppSettings.shared.isRecipeEditLocked {
                        viewModel.moveSteps(from: from, to: to)
                    }
                }
            }

            Button {
                viewModel.isAddingStep = true
            } label: {
                Label(String(localized: "Add Step"), systemImage: "plus.circle.fill")
            }
            .recipeEditLocked(hide: true)
        } header: {
            Text(String(localized: "Steps"))
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showDeleteAlert = true
            } label: {
                Text(String(localized: "Delete Recipe"))
                    .frame(maxWidth: .infinity)
            }
        }
        .recipeEditLocked(hide: true)
    }
}

// MARK: - Step Row View

private struct StepRowView: View {
    let step: StepInput

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)

                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if let line = step.lineIdentifier {
                        Label(line, systemImage: "arrow.branch")
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                }

                if !step.requiredMeasurements.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(step.requiredMeasurements) { measurement in
                            Label(measurement.rawValue, systemImage: measurement.icon)
                                .font(.system(size: 10))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            if step.isTimerRequired {
                Image(systemName: "stopwatch")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Ingredient Row View

private struct IngredientRowView: View {
    let ingredient: IngredientInput
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.inventoryName)
                    .font(.subheadline.weight(.medium))
                if !ingredient.note.isEmpty {
                    Text(ingredient.note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(AppNumberFormatter.format(ingredient.quantity)) \(ingredient.unitSymbol)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !AppSettings.shared.isRecipeEditLocked {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
                .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Add Ingredient Sheet

private struct AddIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \InventoryEntity.name)
    private var inventoryItems: [InventoryEntity]
    
    let onSave: (IngredientInput) -> Void
    
    @State private var selectedItemId: PersistentIdentifier?
    @State private var quantity: Double = 0
    @State private var unitSymbol: String = "g"
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "Item"), selection: $selectedItemId) {
                        Text(String(localized: "Select an item")).tag(nil as PersistentIdentifier?)
                        ForEach(inventoryItems) { item in
                            Text(item.name).tag(item.persistentModelID as PersistentIdentifier?)
                        }
                    }
                }
                
                if let selectedItemId, let item = inventoryItems.first(where: { $0.persistentModelID == selectedItemId }) {
                    Section {
                        HStack {
                            Text(String(localized: "Quantity"))
                            Spacer()
                            TextField("0", value: $quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                            Text(unitSymbol)
                                .foregroundStyle(.secondary)
                        }
                        
                        Picker(String(localized: "Unit"), selection: $unitSymbol) {
                            Text(item.unitSymbol).tag(item.unitSymbol)
                            // Could add other compatible units here
                        }
                    }
                    
                    Section {
                        TextField(String(localized: "Note (optional)"), text: $note)
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
                        if let selectedItemId, let item = inventoryItems.first(where: { $0.persistentModelID == selectedItemId }) {
                            let input = IngredientInput(
                                inventoryId: selectedItemId,
                                inventoryName: item.name,
                                quantity: quantity,
                                unitSymbol: unitSymbol,
                                note: note
                            )
                            onSave(input)
                            dismiss()
                        }
                    }
                    .disabled(selectedItemId == nil || quantity <= 0)
                }
            }
            .onAppear {
                if let first = inventoryItems.first {
                    selectedItemId = first.persistentModelID
                    unitSymbol = first.unitSymbol
                }
            }
            .onChange(of: selectedItemId) { _, newValue in
                if let id = newValue, let item = inventoryItems.first(where: { $0.persistentModelID == id }) {
                    unitSymbol = item.unitSymbol
                }
            }
        }
    }
}

// MARK: - Step Edit Sheet

private struct StepEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var step: StepInput?
    let onSave: (StepInput) -> Void

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var time: Int = 0
    @State private var isTimerRequired: Bool = false
    @State private var requiredMeasurements: [MeasurementType] = []
    @State private var lineIdentifier: String = ""

    private var isEditing: Bool { step != nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Step Title"), text: $title)
                    TextField(String(localized: "Description (optional)"), text: $note, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text(String(localized: "Step Info"))
                }

                Section {
                    TextField(String(localized: "Production Line (optional)"), text: $lineIdentifier)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(String(localized: "Workflow"))
                } footer: {
                    Text(String(localized: "Leave empty for main production line"))
                }

                Section {
                    Toggle(String(localized: "Enable Timer"), isOn: $isTimerRequired)
                } header: {
                    Text(String(localized: "Time"))
                }

                Section {
                    ForEach(MeasurementType.allCases) { type in
                        Toggle(isOn: Binding(
                            get: { requiredMeasurements.contains(type) },
                            set: { isOn in
                                if isOn {
                                    if !requiredMeasurements.contains(type) {
                                        requiredMeasurements.append(type)
                                    }
                                } else {
                                    requiredMeasurements.removeAll { $0 == type }
                                }
                            }
                        )) {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                } header: {
                    Text(String(localized: "Required Measurements"))
                } footer: {
                    Text(String(localized: "User must record these values to complete this step"))
                }
            }
            .navigationTitle(isEditing ? String(localized: "Edit Step") : String(localized: "New Step"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? String(localized: "Save") : String(localized: "Add")) {
                        let resultStep = StepInput(
                            id: step?.id ?? UUID(),
                            title: title.trimmingCharacters(in: .whitespaces),
                            note: note,
                            time: time,
                            isTimerRequired: isTimerRequired,
                            requiredMeasurements: requiredMeasurements,
                            lineIdentifier: lineIdentifier.isEmpty ? nil : lineIdentifier.trimmingCharacters(in: .whitespaces)
                        )
                        onSave(resultStep)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let step {
                    title = step.title
                    note = step.note
                    time = step.time
                    isTimerRequired = step.isTimerRequired
                    requiredMeasurements = step.requiredMeasurements
                    lineIdentifier = step.lineIdentifier ?? ""
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
