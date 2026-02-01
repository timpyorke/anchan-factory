import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingViewModel()

    @Query(sort: \CustomUnitEntity.name)
    private var customUnits: [CustomUnitEntity]

    var body: some View {
        Form {
            appearanceSection
            languageSection
            customUnitsSection
            exportSection
            dataSection
        }
        .navigationTitle(String(localized: "Settings"))
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $viewModel.showAddUnitSheet) {
            AddCustomUnitSheet()
        }
        .alert(String(localized: "Clear All Data"), isPresented: $viewModel.showClearDataAlert) {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button(String(localized: "Clear"), role: .destructive) {
                viewModel.clearAllData()
            }
        } message: {
            Text(String(localized: "This will delete all recipes, inventory, and manufacturing data. This action cannot be undone."))
        }
        .alert(String(localized: "Restart Required"), isPresented: $viewModel.showRestartAlert) {
            Button(String(localized: "OK")) { }
        } message: {
            Text(String(localized: "Please restart the app to apply the language change."))
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            Picker(selection: Bindable(viewModel.settings).theme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.displayName, systemImage: theme.icon)
                        .tag(theme)
                }
            } label: {
                Label(String(localized: "Theme"), systemImage: "paintbrush.fill")
            }
        } header: {
            Text(String(localized: "Appearance"))
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        Section {
            Picker(selection: Bindable(viewModel.settings).language) {
                ForEach(AppLanguage.allCases) { lang in
                    Text("\(lang.flag) \(lang.displayName)")
                        .tag(lang)
                }
            } label: {
                Label(String(localized: "Language"), systemImage: "globe")
            }
            .onChange(of: viewModel.settings.language) { _, _ in
                viewModel.showRestartAlert = true
            }
        } header: {
            Text(String(localized: "Language"))
        } footer: {
            Text(String(localized: "Restart required to apply language change"))
        }
    }

    // MARK: - Custom Units Section

    private var customUnitsSection: some View {
        Section {
            ForEach(customUnits, id: \.persistentModelID) { unit in
                HStack {
                    Text(unit.name)
                    Spacer()
                    Text(unit.symbol.uppercased())
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { offsets in
                viewModel.deleteUnits(at: offsets, from: customUnits)
            }

            Button {
                viewModel.showAddUnitSheet = true
            } label: {
                Label(String(localized: "Add Custom Unit"), systemImage: "plus.circle.fill")
            }
        } header: {
            Text(String(localized: "Custom Units"))
        } footer: {
            Text(String(localized: "Add custom measurement units for your inventory"))
        }
    }

    // MARK: - Export Section

    private var exportSection: some View {
        Section {
            Button {
                viewModel.exportManufacturingData()
            } label: {
                Label(String(localized: "Export Manufacturing Data"), systemImage: "tablecells")
            }

            Button {
                viewModel.exportInventoryData()
            } label: {
                Label(String(localized: "Export Inventory Data"), systemImage: "shippingbox")
            }

            Button {
                viewModel.exportRecipeData()
            } label: {
                Label(String(localized: "Export Recipe Data"), systemImage: "book")
            }
        } header: {
            Text(String(localized: "Export"))
        } footer: {
            Text(String(localized: "Export data as CSV for Google Sheets or Excel"))
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showClearDataAlert = true
            } label: {
                Label(String(localized: "Clear All Data"), systemImage: "trash.fill")
            }
        } header: {
            Text(String(localized: "Data Management"))
        } footer: {
            Text(String(localized: "Permanently delete all app data"))
        }
    }
}

// MARK: - Add Custom Unit Sheet

private struct AddCustomUnitSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var symbol = ""
    @State private var name = ""

    private var canSave: Bool {
        !symbol.trimmingCharacters(in: .whitespaces).isEmpty &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Symbol (e.g., cup, tbsp)"), text: $symbol)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField(String(localized: "Name (e.g., Cup, Tablespoon)"), text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(String(localized: "Unit Details"))
                } footer: {
                    Text(String(localized: "Symbol will be displayed in uppercase"))
                }
            }
            .navigationTitle(String(localized: "Add Custom Unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        saveUnit()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
    }

    private func saveUnit() {
        let unit = CustomUnitEntity(
            symbol: symbol.trimmingCharacters(in: .whitespaces),
            name: name.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(unit)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
    .modelContainer(AppModelContainer.make())
}
