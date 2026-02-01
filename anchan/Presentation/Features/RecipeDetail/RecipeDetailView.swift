import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter
    @State private var viewModel = RecipeDetailViewModel()

    let id: PersistentIdentifier

    @State private var recipe: RecipeEntity?
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if let recipe {
                recipeContent(recipe)
            } else {
                ContentUnavailableView("Recipe Not Found", systemImage: "book")
            }
        }
        .navigationTitle(recipe?.name ?? "Recipe")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if recipe != nil {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            stackRouter.push(.recipeEdit(id: id))
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button {
                            recipe?.isFavorite.toggle()
                        } label: {
                            Label(
                                recipe?.isFavorite == true ? "Unfavorite" : "Favorite",
                                systemImage: recipe?.isFavorite == true ? "heart.slash" : "heart"
                            )
                        }

                        Divider()

                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRecipe()
            }
        } message: {
            Text("Are you sure you want to delete this recipe?")
        }
        .onAppear {
            loadRecipe()
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

            HStack(spacing: 16) {
                if recipe.totalTime > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(recipe.totalTime.formattedTime)
                    }
                }

                if recipe.totalCost > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "banknote")
                        Text("฿\(recipe.totalCost.clean)")
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private func stepsSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Steps")
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

                                if step.time > 0 {
                                    Label(step.time.formattedTime, systemImage: "clock")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
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
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func ingredientsSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients")
                    .font(.title2.bold())

                if !recipe.hasEnoughInventory {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }

                Spacer()

                if recipe.totalCost > 0 {
                    Text("฿\(recipe.totalCost.clean)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Warning banner if insufficient
            if !recipe.hasEnoughInventory {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("\(recipe.insufficientCount) ingredient\(recipe.insufficientCount > 1 ? "s" : "") with insufficient stock")
                }
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recipe.ingredients), id: \.persistentModelID) { ingredient in
                    ingredientRow(ingredient)
                }
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func ingredientRow(_ ingredient: IngredientEntity) -> some View {
        let hasStock = ingredient.hasEnoughStock
        let cost = ingredient.quantity * ingredient.inventoryItem.unitPrice
        return HStack {
            Image(systemName: hasStock ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundStyle(hasStock ? Color.green : Color.orange)

            Text(ingredient.inventoryItem.name)
                .foregroundStyle(hasStock ? Color.primary : Color.orange)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(ingredient.quantity.clean) \(ingredient.unit.symbol)")
                    .foregroundStyle(.secondary)

                if !hasStock {
                    Text("Stock: \(ingredient.inventoryItem.stock.clean)")
                        .font(.caption2)
                        .foregroundStyle(Color.orange)
                } else if cost > 0 {
                    Text("฿\(cost.clean)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private func notesSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.title2.bold())

            Text(recipe.note)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func loadRecipe() {
        recipe = modelContext.model(for: id) as? RecipeEntity
    }

    private func deleteRecipe() {
        if let recipe {
            modelContext.delete(recipe)
        }
        stackRouter.pop()
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
    }
    .modelContainer(AppModelContainer.make())
}
