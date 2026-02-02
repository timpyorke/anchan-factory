import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
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

            if viewModel.items.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddSheet) {
            InventoryAddView {
                viewModel.loadItems()
            }
        }
        .sheet(isPresented: $viewModel.isShowingEditSheet) {
            if let item = viewModel.editingItem {
                InventoryAddView(editingItem: item) {
                    viewModel.loadItems()
                }
            }
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
        List {
            ForEach(viewModel.filteredItems, id: \.persistentModelID) { item in
                InventoryRowView(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.edit(item)
                    }
            }
            .onDelete(perform: viewModel.deleteItems)
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
                    Label("\(item.stock.clean) \(item.displaySymbol)", systemImage: "shippingbox")
                    Label("\(item.unitPrice.clean) / \(item.displaySymbol)", systemImage: "tag")
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
