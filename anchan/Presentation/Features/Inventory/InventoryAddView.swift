import SwiftUI
import SwiftData

struct InventoryAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CustomUnitEntity.name)
    private var customUnits: [CustomUnitEntity]

    @State private var name: String = ""
    @State private var category: String = ""
    @State private var unitSymbol: String = "g"
    @State private var unitPrice: String = ""
    @State private var stock: String = ""
    @State private var minStock: String = ""

    private let editingItem: InventoryEntity?
    var onSave: (() -> Void)?

    private var isEditing: Bool { editingItem != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displaySymbol: String {
        unitSymbol.uppercased()
    }

    // MARK: - Init

    init(editingItem: InventoryEntity? = nil, onSave: (() -> Void)? = nil) {
        self.editingItem = editingItem
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Category (optional)", text: $category)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Item Details")
                }

                Section {
                    Picker("Unit", selection: $unitSymbol) {
                        // Built-in units
                        ForEach(InventoryUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit.rawValue)
                        }

                        // Custom units
                        if !customUnits.isEmpty {
                            Divider()
                            ForEach(customUnits, id: \.persistentModelID) { unit in
                                Text("\(unit.name) (\(unit.symbol.uppercased()))").tag(unit.symbol)
                            }
                        }
                    }

                    HStack {
                        Text("Price per \(displaySymbol)")
                        Spacer()
                        TextField("0", text: $unitPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }

                    HStack {
                        Text("Current stock")
                        Spacer()
                        TextField("0", text: $stock)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(displaySymbol)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Unit & Pricing")
                }

                Section {
                    HStack {
                        Text("Minimum stock")
                        Spacer()
                        TextField("0", text: $minStock)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(displaySymbol)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Restock Alert")
                } footer: {
                    Text("Get notified when stock falls below this level")
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteItem()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Item")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                loadEditingItem()
            }
        }
    }

    // MARK: - Actions

    private func loadEditingItem() {
        guard let item = editingItem else { return }
        name = item.name
        category = item.category ?? ""
        unitSymbol = item.unitSymbol
        unitPrice = item.unitPrice > 0 ? String(item.unitPrice) : ""
        stock = item.stock > 0 ? String(item.stock) : ""
        minStock = item.minStock > 0 ? String(item.minStock) : ""
    }

    private func saveItem() {
        let price = Double(unitPrice) ?? 0
        let stockValue = Double(stock) ?? 0
        let minStockValue = Double(minStock) ?? 0

        if let item = editingItem {
            // Update existing
            item.name = name.trimmingCharacters(in: .whitespaces)
            item.category = category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)
            item.unitSymbol = unitSymbol
            item.unitPrice = price
            item.stock = stockValue
            item.minStock = minStockValue
        } else {
            // Create new
            let item = InventoryEntity(
                name: name.trimmingCharacters(in: .whitespaces),
                unitSymbol: unitSymbol,
                unitPrice: price,
                stock: stockValue,
                minStock: minStockValue
            )
            if !category.isEmpty {
                item.category = category.trimmingCharacters(in: .whitespaces)
            }
            modelContext.insert(item)
        }

        onSave?()
        dismiss()
    }

    private func deleteItem() {
        if let item = editingItem {
            modelContext.delete(item)
        }
        onSave?()
        dismiss()
    }
}

#Preview("Add") {
    InventoryAddView()
        .modelContainer(AppModelContainer.make())
}
