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

    /// Convert a value from this unit to the target unit
    /// Returns nil if units are incompatible (e.g., g to ml)
    func convert(_ value: Double, to target: InventoryUnit) -> Double? {
        if self == target { return value }

        switch (self, target) {
        // Mass conversions
        case (.g, .kg): return value / 1000
        case (.kg, .g): return value * 1000
        // Volume conversions
        case (.ml, .l): return value / 1000
        case (.l, .ml): return value * 1000
        // Incompatible units
        default: return nil
        }
    }
}
