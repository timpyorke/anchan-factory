import SwiftUI
import SwiftData

// MARK: - Step Input Model

struct StepInput: Identifiable {
    let id = UUID()
    var title: String
    var note: String
    var time: Int
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
    @State private var isAddingStep: Bool = false
    @State private var showDeleteAlert: Bool = false

    private var isEditing: Bool { id != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var totalTime: Int {
        steps.reduce(0) { $0 + $1.time }
    }

    var body: some View {
        Form {
            basicInfoSection
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
