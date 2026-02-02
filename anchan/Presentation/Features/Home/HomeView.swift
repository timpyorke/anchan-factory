import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let tabRouter: TabRouter
    let stackRouter: StackRouter

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Low Stock Alert Section
                if !viewModel.lowStockItems.isEmpty {
                    lowStockSection
                }

                // New Manufacturing Button
                newManufacturingButton

                // Active Manufacturing Section
                if !viewModel.activeManufacturing.isEmpty {
                    activeSection
                }

                // Completed Section
                if !viewModel.completedManufacturing.isEmpty {
                    completedSection
                }

                // Empty State
                if viewModel.activeManufacturing.isEmpty && viewModel.completedManufacturing.isEmpty && viewModel.lowStockItems.isEmpty {
                    emptyState
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "Manufacturing"))
        .sheet(isPresented: $viewModel.showRecipeSelection) {
            RecipeSelectionSheet { recipe in
                handleRecipeSelection(recipe)
            }
        }
        .alert(String(localized: "Insufficient Inventory"), isPresented: $viewModel.showInsufficientAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {
                viewModel.selectedRecipe = nil
            }
            Button(String(localized: "Start Anyway"), role: .destructive) {
                if let recipe = viewModel.selectedRecipe {
                    let id = viewModel.startManufacturing(with: recipe)
                    stackRouter.push(.manufacturingProcess(id: id))
                    viewModel.selectedRecipe = nil
                }
            }
        } message: {
            if let recipe = viewModel.selectedRecipe {
                let items = recipe.insufficientIngredients
                    .map { "\($0.inventoryItem.name) (need \($0.quantity.clean) \($0.displaySymbol), have \($0.inventoryItem.stock.clean) \($0.inventoryItem.displaySymbol))" }
                    .joined(separator: "\n")
                Text("The following ingredients don't have enough stock:\n\n\(items)")
            }
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }

    // MARK: - Components

    private var newManufacturingButton: some View {
        Button {
            viewModel.showRecipeSelection = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "New Manufacturing"))
                        .font(.headline)
                    Text(String(localized: "Select a recipe to start"))
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

    private var lowStockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(String(localized: "Low Stock"))
                    .font(.title3.bold())

                Spacer()

                Button {
                    tabRouter.go(to: .inventory)
                } label: {
                    Text(String(localized: "View All"))
                        .font(.subheadline)
                }
            }

            VStack(spacing: 8) {
                ForEach(viewModel.lowStockItems.prefix(5), id: \.persistentModelID) { item in
                    LowStockRow(item: item) {
                        tabRouter.go(to: .inventory)
                    }
                }
            }
        }
        .padding()
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "In Progress"))
                .font(.title3.bold())

            ForEach(viewModel.activeManufacturing, id: \.persistentModelID) { item in
                ManufacturingCard(manufacturing: item) {
                    stackRouter.push(.manufacturingProcess(id: item.persistentModelID))
                }
            }
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "Recently Completed"))
                    .font(.title3.bold())

                Spacer()

                if viewModel.completedManufacturing.count > 5 {
                    Button(String(localized: "See All")) {
                        // Future: Show all completed
                    }
                    .font(.subheadline)
                }
            }

            ForEach(viewModel.completedManufacturing.prefix(5), id: \.persistentModelID) { item in
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

            Text(String(localized: "No Manufacturing Yet"))
                .font(.headline)

            Text(String(localized: "Tap the button above to start manufacturing a recipe"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Actions

    private func handleRecipeSelection(_ recipe: RecipeEntity) {
        if viewModel.handleRecipeSelection(recipe) {
            let id = viewModel.startManufacturing(with: recipe)
            stackRouter.push(.manufacturingProcess(id: id))
        } else {
            viewModel.showInsufficientAlert = true
        }
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
                        HStack(spacing: 8) {
                            Text(manufacturing.recipe.name)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("#\(manufacturing.batchNumber)")
                                .font(.caption.monospaced())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }

                        Text(String(localized: "Step \(manufacturing.currentStepIndex + 1) of \(manufacturing.totalSteps)"))
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
                    HStack(spacing: 6) {
                        Text(manufacturing.recipe.name)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Text("#\(manufacturing.batchNumber)")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                    }

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

    @State private var viewModel = RecipeSelectionViewModel()

    let onSelect: (RecipeEntity) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recipes.isEmpty {
                    ContentUnavailableView(
                        String(localized: "No Recipes"),
                        systemImage: "book",
                        description: Text(String(localized: "Create a recipe first to start manufacturing"))
                    )
                } else {
                    List(viewModel.filteredRecipes, id: \.persistentModelID) { recipe in
                        Button {
                            onSelect(recipe)
                            dismiss()
                        } label: {
                            RecipeSelectionRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                    .searchable(text: $viewModel.searchText, prompt: String(localized: "Search recipes"))
                }
            }
            .navigationTitle(String(localized: "Select Recipe"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Recipe Selection Row

private struct RecipeSelectionRow: View {
    let recipe: RecipeEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    // Warning badge for insufficient inventory
                    if !recipe.hasEnoughInventory {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                HStack(spacing: 12) {
                    if recipe.totalTime > 0 {
                        Label(recipe.totalTime.formattedTime, systemImage: "clock")
                    }

                    Label("\(recipe.steps.count) \(String(localized: "steps"))", systemImage: "list.number")

                    if recipe.totalCost > 0 {
                        Label("฿\(recipe.totalCost.clean)", systemImage: "banknote")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                // Show insufficient ingredients warning
                if !recipe.hasEnoughInventory {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle")
                        let pluralSuffix = recipe.insufficientCount > 1 ? "s" : ""
                        Text(String(localized: "\(recipe.insufficientCount) ingredient\(pluralSuffix) insufficient"))
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Low Stock Row

private struct LowStockRow: View {
    let item: InventoryEntity
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Stock level indicator
                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Circle()
                        .trim(from: 0, to: item.stockLevel)
                        .stroke(stockColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(item.stockLevel * 100))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(stockColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    Text("\(item.stock.clean) / \(item.minStock.clean) \(item.displaySymbol)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Restock suggestion
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(localized: "Restock"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("+\(item.restockAmount.clean) \(item.displaySymbol)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var stockColor: Color {
        if item.stockLevel < 0.25 {
            return .red
        } else if item.stockLevel < 0.5 {
            return .orange
        } else {
            return .yellow
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(tabRouter: TabRouter(), stackRouter: StackRouter())
    }
    .modelContainer(AppModelContainer.make())
}
