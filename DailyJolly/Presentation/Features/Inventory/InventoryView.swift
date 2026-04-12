import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryEntity.name) private var items: [InventoryEntity]
    
    @State private var viewModel = InventoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            AppBarView(title: String(localized: "Inventory")) {
                EmptyView()
            } trailing: {
                Button {
                    viewModel.isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }

            if items.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddSheet) {
            InventoryAddView {
                // Refresh handled by @Query
            }
        }
        .sheet(isPresented: $viewModel.isShowingEditSheet) {
            if let item = viewModel.editingItem {
                InventoryAddView(editingItem: item) {
                    // Refresh handled by @Query
                }
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
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No Items"), systemImage: "archivebox")
        } description: {
            Text(String(localized: "Add your first inventory item to get started."))
        } actions: {
            Button {
                viewModel.isShowingAddSheet = true
            } label: {
                Text(String(localized: "Add Item"))
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - List Content

    private var listContent: some View {
        let filteredItems = items.filter { item in
            viewModel.searchText.isEmpty || item.name.localizedCaseInsensitiveContains(viewModel.searchText)
        }
        
        return List {
            ForEach(filteredItems, id: \.persistentModelID) { item in
                ListRow(action: {
                    viewModel.edit(item)
                }) {
                    InventoryRowView(item: item)
                }
            }
            .onDelete { offsets in
                let itemsToDelete = offsets.map { filteredItems[$0] }
                for item in itemsToDelete {
                    modelContext.delete(item)
                }
                try? modelContext.save()
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: String(localized: "Search inventory"))
    }
}

// MARK: - Row View

private struct InventoryRowView: View {
    let item: InventoryEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)

                    if let category = item.category {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.fill.tertiary)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    Label("\(AppNumberFormatter.format(item.stock)) \(item.displaySymbol)", systemImage: "shippingbox")
                    Label("\(AppNumberFormatter.format(item.unitPrice)) / \(item.displaySymbol)", systemImage: "tag")
                    if let ph = item.phValue {
                        Label("pH \(AppNumberFormatter.format(ph))", systemImage: "drop.fill")
                            .foregroundStyle(.blue)
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
    InventoryView()
        .modelContainer(AppModelContainer.make())
}
