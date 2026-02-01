enum InventoryUnit: String, CaseIterable, Identifiable, Codable {
    case g, kg, ml, l, pcs

    var id: Self { self }

    var displayName: String {
        switch self {
        case .g: return "grams"
        case .kg: return "kilograms"
        case .ml: return "milliliters"
        case .l: return "liters"
        case .pcs: return "pieces"
        }
    }
}
