import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let tabRouter: TabRouter
    let stackRouter: StackRouter

    @State private var viewModel = HomeViewModel()
    @State private var showRecipeSelection = false

    @Query(sort: \ManufacturingEntity.startedAt, order: .reverse)
    private var allManufacturing: [ManufacturingEntity]

    private var activeManufacturing: [ManufacturingEntity] {
        allManufacturing.filter { $0.status == .inProgress }
    }

    private var completedManufacturing: [ManufacturingEntity] {
        allManufacturing.filter { $0.status == .completed }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // New Manufacturing Button
                newManufacturingButton

                // Active Manufacturing Section
                if !activeManufacturing.isEmpty {
                    activeSection
                }

                // Completed Section
                if !completedManufacturing.isEmpty {
                    completedSection
                }

                // Empty State
                if activeManufacturing.isEmpty && completedManufacturing.isEmpty {
                    emptyState
                }
            }
            .padding()
        }
        .navigationTitle("Manufacturing")
        .sheet(isPresented: $showRecipeSelection) {
            RecipeSelectionSheet { recipe in
                startManufacturing(with: recipe)
            }
        }
    }

    // MARK: - Components

    private var newManufacturingButton: some View {
        Button {
            showRecipeSelection = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("New Manufacturing")
                        .font(.headline)
                    Text("Select a recipe to start")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("In Progress")
                .font(.title3.bold())

            ForEach(activeManufacturing, id: \.persistentModelID) { item in
                ManufacturingCard(manufacturing: item) {
                    stackRouter.push(.manufacturingProcess(id: item.persistentModelID))
                }
            }
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recently Completed")
                    .font(.title3.bold())

                Spacer()

                if completedManufacturing.count > 5 {
                    Button("See All") {
                        // Future: Show all completed
                    }
                    .font(.subheadline)
                }
            }

            ForEach(completedManufacturing.prefix(5), id: \.persistentModelID) { item in
                CompletedManufacturingRow(manufacturing: item) {
                    stackRouter.push(.manufacturingDetail(id: item.persistentModelID))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Manufacturing Yet")
                .font(.headline)

            Text("Tap the button above to start manufacturing a recipe")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Actions

    private func startManufacturing(with recipe: RecipeEntity) {
        let manufacturing = ManufacturingEntity(recipe: recipe)
        modelContext.insert(manufacturing)

        // Navigate to manufacturing view
        stackRouter.push(.manufacturingProcess(id: manufacturing.persistentModelID))
    }
}

// MARK: - Manufacturing Card

private struct ManufacturingCard: View {
    let manufacturing: ManufacturingEntity
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(manufacturing.recipe.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Step \(manufacturing.currentStepIndex + 1) of \(manufacturing.totalSteps)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.fill.tertiary)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * manufacturing.progress, height: 6)
                    }
                }
                .frame(height: 6)

                // Current Step Preview
                if let currentStep = manufacturing.currentStep {
                    Text(currentStep.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Completed Manufacturing Row

private struct CompletedManufacturingRow: View {
    let manufacturing: ManufacturingEntity
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text(manufacturing.recipe.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    if let completedAt = manufacturing.completedAt {
                        Text(completedAt, format: .dateTime.month().day().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recipe Selection Sheet

private struct RecipeSelectionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var recipes: [RecipeEntity] = []
    @State private var searchText: String = ""

    let onSelect: (RecipeEntity) -> Void

    private var filteredRecipes: [RecipeEntity] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book",
                        description: Text("Create a recipe first to start manufacturing")
                    )
                } else {
                    List(filteredRecipes, id: \.persistentModelID) { recipe in
                        Button {
                            onSelect(recipe)
                            dismiss()
                        } label: {
                            RecipeSelectionRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                    .searchable(text: $searchText, prompt: "Search recipes")
                }
            }
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadRecipes()
            }
        }
    }

    private func loadRecipes() {
        let descriptor = FetchDescriptor<RecipeEntity>(
            sortBy: [SortDescriptor(\.name)]
        )
        recipes = (try? modelContext.fetch(descriptor)) ?? []
    }
}

// MARK: - Recipe Selection Row

private struct RecipeSelectionRow: View {
    let recipe: RecipeEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    if recipe.totalTime > 0 {
                        Label(recipe.totalTime.formattedTime, systemImage: "clock")
                    }

                    Label("\(recipe.steps.count) steps", systemImage: "list.number")

                    if recipe.totalCost > 0 {
                        Label("฿\(recipe.totalCost.clean)", systemImage: "banknote")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HomeView(tabRouter: TabRouter(), stackRouter: StackRouter())
    }
    .modelContainer(AppModelContainer.make())
}
