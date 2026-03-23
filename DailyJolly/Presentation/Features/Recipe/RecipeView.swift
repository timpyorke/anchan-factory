import SwiftUI
import SwiftData

struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    let stackRouter: StackRouter
    @State private var viewModel = RecipeViewModel()
    @State private var showPinVerify = false

    var body: some View {
        VStack(spacing: 0) {
            AppBarView(title: String(localized: "Recipes")) {
                if AppSettings.shared.isRecipeEditLocked {
                    Button {
                        showPinVerify = true
                    } label: {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.orange)
                    }
                } else {
                    EmptyView()
                }
            } trailing: {
                if !AppSettings.shared.isRecipeEditLocked {
                    Button {
                        stackRouter.push(.recipeAdd)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }

            if viewModel.recipes.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .sheet(isPresented: $showPinVerify) {
            PinEntryView(mode: .verify) { _ in
                AppSettings.shared.isRecipeEditLocked = false
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No Recipes"), systemImage: "book")
        } description: {
            Text(String(localized: "Add your first recipe to get started."))
        } actions: {
            if !AppSettings.shared.isRecipeEditLocked {
                Button {
                    stackRouter.push(.recipeAdd)
                } label: {
                    Text(String(localized: "Add Recipe"))
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - List Content

    private var listContent: some View {
        List {
            ForEach(viewModel.filteredRecipes, id: \.persistentModelID) { recipe in
                RecipeRowView(recipe: recipe)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        stackRouter.push(.recipeDetail(id: recipe.persistentModelID))
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.toggleFavorite(recipe)
                        } label: {
                            Image(systemName: recipe.isFavorite ? "heart.slash" : "heart")
                        }
                        .tint(recipe.isFavorite ? .gray : .pink)

                        if !AppSettings.shared.isRecipeEditLocked {
                            Button {
                                viewModel.duplicateRecipe(recipe)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .tint(.blue)
                        }
                    }
            }
            .onDelete { offsets in
                if !AppSettings.shared.isRecipeEditLocked {
                    viewModel.deleteRecipes(at: offsets)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: String(localized: "Search recipes"))
    }
}

// MARK: - Row View

private struct RecipeRowView: View {
    let recipe: RecipeEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)

                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.pink)
                    }

                    if let category = recipe.category {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.fill.tertiary)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    if !recipe.steps.isEmpty {
                        Label("\(recipe.steps.count) \(String(localized: "steps"))", systemImage: "list.number")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecipeView(stackRouter: StackRouter())
        .modelContainer(AppModelContainer.make())
}
