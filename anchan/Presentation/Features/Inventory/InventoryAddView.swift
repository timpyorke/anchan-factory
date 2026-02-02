import SwiftUI
import SwiftData

struct InventoryAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: InventoryAddViewModel
    var onSave: (() -> Void)?

    // MARK: - Init

    init(editingItem: InventoryEntity? = nil, onSave: (() -> Void)? = nil) {
        _viewModel = State(initialValue: InventoryAddViewModel(editingItem: editingItem))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Name"), text: $viewModel.name)
                        .textInputAutocapitalization(.words)

                    TextField(String(localized: "Category (optional)"), text: $viewModel.category)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(String(localized: "Item Details"))
                }

                Section {
                    Picker(String(localized: "Unit"), selection: $viewModel.unitSymbol) {
                        // Built-in units
                        ForEach(InventoryUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit.rawValue)
                        }

                        // Custom units
                        if !viewModel.customUnits.isEmpty {
                            Divider()
                            ForEach(viewModel.customUnits, id: \.persistentModelID) { unit in
                                Text("\(unit.name) (\(unit.symbol.uppercased()))").tag(unit.symbol)
                            }
                        }
                    }

                    HStack {
                        Text(String(localized: "Price per \(viewModel.displaySymbol)"))
                        Spacer()
                        TextField("0", text: $viewModel.unitPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text(String(localized: "Current stock"))
                        Spacer()
                        TextField("0", text: $viewModel.stock)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(viewModel.displaySymbol)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(String(localized: "Unit & Pricing"))
                }

                Section {
                    HStack {
                        Text(String(localized: "Minimum stock"))
                        Spacer()
                        TextField("0", text: $viewModel.minStock)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(viewModel.displaySymbol)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(String(localized: "Restock Alert"))
                } footer: {
                    Text(String(localized: "Get notified when stock falls below this level"))
                }

                if viewModel.isEditing {
                    Section {
                        Button(role: .destructive) {
                            viewModel.deleteItem {
                                onSave?()
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text(String(localized: "Delete Item"))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? String(localized: "Edit Item") : String(localized: "New Item"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        viewModel.saveItem {
                            onSave?()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

}

#Preview("Add") {
    InventoryAddView()
        .modelContainer(AppModelContainer.make())
}
