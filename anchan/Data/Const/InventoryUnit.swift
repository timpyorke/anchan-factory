enum InventoryUnit: String, CaseIterable, Identifiable, Codable {
    case g, kg, ml, l, pcs

    var id: Self { self }

    /// Short symbol for compact display (e.g., "g", "kg")
    var symbol: String {
        rawValue.uppercased()
    }

    /// Full name for forms and pickers (e.g., "Grams", "Kilograms")
    var displayName: String {
        switch self {
        case .g: return "Grams (g)"
        case .kg: return "Kilograms (kg)"
        case .ml: return "Milliliters (ml)"
        case .l: return "Liters (l)"
        case .pcs: return "Pieces (pcs)"
        }
    }
}
