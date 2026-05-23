import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter
    @State private var viewModel = RecipeDetailViewModel()

    let id: PersistentIdentifier

    var body: some View {
        Group {
            if viewModel.isDeleting {
                ProgressView(String(localized: "Deleting..."))
                    .frame(maxHeight: .infinity)
            } else if let recipe = viewModel.recipe {
                recipeContent(recipe)
            } else {
                ContentUnavailableView(String(localized: "Recipe Not Found"), systemImage: "book")
            }
        }
        .navigationTitle(viewModel.recipeName.isEmpty ? String(localized: "Recipe") : viewModel.recipeName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.recipe != nil {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            stackRouter.push(.recipeEdit(id: id))
                        } label: {
                            Label(String(localized: "Edit"), systemImage: "pencil")
                        }
                        .recipeEditLocked(hide: true)

                        Button {
                            viewModel.toggleFavorite()
                        } label: {
                            Label(
                                viewModel.recipe?.isFavorite == true ? String(localized: "Unfavorite") : String(localized: "Favorite"),
                                systemImage: viewModel.recipe?.isFavorite == true ? "heart.slash" : "heart"
                            )
                        }

                        Button {
                            viewModel.duplicateRecipe { newId in
                                stackRouter.push(.recipeDetail(id: newId))
                            }
                        } label: {
                            Label(String(localized: "Duplicate"), systemImage: "doc.on.doc")
                        }
                        .recipeEditLocked(hide: true)

                        Divider()
                            .recipeEditLocked(hide: true)

                        Button(role: .destructive) {
                            viewModel.showDeleteAlert = true
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                        .recipeEditLocked(hide: true)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert(String(localized: "Delete Recipe"), isPresented: $viewModel.showDeleteAlert) {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button(String(localized: "Delete"), role: .destructive) {
                viewModel.deleteRecipe {
                    stackRouter.pop()
                }
            }
        } message: {
            if let recipe = viewModel.recipe, !recipe.manufacturingRecords.isEmpty {
                Text(String(localized: "This recipe has \(recipe.manufacturingRecords.count) manufacturing records. Deleting it will also delete all associated history. Are you sure?"))
            } else {
                Text(String(localized: "Are you sure you want to delete this recipe?"))
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, recipeId: id)
        }
    }

    // MARK: - Content

    private func recipeContent(_ recipe: RecipeEntity) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection(recipe)

                if !recipe.steps.isEmpty {
                    stepsSection(recipe)
                }

                if !recipe.ingredients.isEmpty {
                    ingredientsSection(recipe)
                }

                if !recipe.note.isEmpty {
                    notesSection(recipe)
                }
            }
            .padding()
        }
    }

    private func headerSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let category = recipe.category {
                    Text(category)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.fill.tertiary)
                        .clipShape(Capsule())
                }

                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                }
            }

            // Target Batch Scaling
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Target Output"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("\(viewModel.scaledOutput) \(recipe.batchUnit)")
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                Stepper("", value: $viewModel.targetBatchCount, in: 1...100)
                    .labelsHidden()
            }
            .padding()
            .liquidGlassMaterial(cornerRadius: 12)

            // Cost breakdown
            if recipe.totalCost > 0 {
                costBreakdownView(recipe)
            }
        }
    }

    private func costBreakdownView(_ recipe: RecipeEntity) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(localized: "Total Cost"))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.format(viewModel.scaledTotalCost))
                    .fontWeight(.medium)
            }

            HStack {
                Text(String(localized: "Cost per \(recipe.batchUnit)"))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.format(recipe.costPerUnit))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .font(.subheadline)
        .padding()
        .background(.fill.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func stepsSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Steps"))
                .font(.title2.bold())

            VStack(spacing: 0) {
                ForEach(Array(recipe.sortedSteps.enumerated()), id: \.element.persistentModelID) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.accentColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(step.title)
                                    .font(.headline)

                                Spacer()
                            }

                            if !step.note.isEmpty {
                                Text(step.note)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 12)

                    if index < recipe.steps.count - 1 {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            .padding()
            .liquidGlassMaterial(cornerRadius: 12)
        }
    }

    private func ingredientsSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "Ingredients"))
                    .font(.title2.bold())

                if !hasEnoughScaledInventory(recipe) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }

                Spacer()

                if recipe.totalCost > 0 {
                    Text(CurrencyFormatter.format(viewModel.scaledTotalCost))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Warning banner if insufficient
            if !hasEnoughScaledInventory(recipe) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    let count = insufficientScaledCount(recipe)
                    let pluralSuffix = count > 1 ? "s" : ""
                    Text(String(localized: "\(count) ingredient\(pluralSuffix) with insufficient stock"))
                }
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .liquidGlassCard(tint: .orange, opacity: 0.18, cornerRadius: 8)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recipe.ingredients), id: \.persistentModelID) { ingredient in
                    ingredientRow(ingredient)
                }
            }
            .padding()
            .liquidGlassMaterial(cornerRadius: 12)
        }
    }

    private func ingredientRow(_ ingredient: IngredientEntity) -> some View {
        let scaledQuantity = ingredient.quantity * Double(viewModel.targetBatchCount)
        let scaledBaseQuantity = ingredient.quantityInBaseUnit * Double(viewModel.targetBatchCount)
        let hasStock = ingredient.inventoryItem.stock >= scaledBaseQuantity
        let scaledCost = scaledBaseQuantity * ingredient.inventoryItem.unitPrice
        
        return HStack {
            Image(systemName: hasStock ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundStyle(hasStock ? Color.green : Color.orange)

            Text(ingredient.inventoryItem.name)
                .foregroundStyle(hasStock ? Color.primary : Color.orange)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(AppNumberFormatter.format(scaledQuantity)) \(ingredient.displaySymbol)")
                    .foregroundStyle(.secondary)

                if !hasStock {
                    Text(String(localized: "Stock: \(AppNumberFormatter.format(ingredient.inventoryItem.stock)) \(ingredient.inventoryItem.displaySymbol)"))
                        .font(.caption2)
                        .foregroundStyle(Color.orange)
                } else if scaledCost > 0 {
                    Text(CurrencyFormatter.format(scaledCost))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    private func hasEnoughScaledInventory(_ recipe: RecipeEntity) -> Bool {
        return insufficientScaledCount(recipe) == 0
    }
    
    private func insufficientScaledCount(_ recipe: RecipeEntity) -> Int {
        recipe.ingredients.filter { ingredient in
            let scaledBaseQuantity = ingredient.quantityInBaseUnit * Double(viewModel.targetBatchCount)
            return ingredient.inventoryItem.stock < scaledBaseQuantity
        }.count
    }

    private func notesSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Notes"))
                .font(.title2.bold())

            Text(recipe.note)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

}

#Preview {
    NavigationStack {
        Text("Preview")
    }
    .modelContainer(AppModelContainer.make())
}
