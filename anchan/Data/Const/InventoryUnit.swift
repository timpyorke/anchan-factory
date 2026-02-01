enum InventoryUnit: String, CaseIterable, Identifiable {
    case g, kg, ml, l, pcs

    var id: Self { self }
}
