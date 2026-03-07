import Foundation

/// Represents the types of gelling agents that define the production technique.
enum GellingAgentType: String, Codable, CaseIterable, Identifiable {
    case pectin = "Pectin"
    case gelatin = "Gelatin"
    case agar = "Agar-Agar"
    case carrageenan = "Carrageenan"
    case starch = "Starch"

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .pectin: return "High-temperature cooking, pH sensitive"
        case .gelatin: return "Hydration required, low temperature set"
        case .agar: return "High-temperature activation, heat stable"
        case .carrageenan: return "Shear thinning, thermoreversible"
        case .starch: return "Gelatinization at specific temperature"
        }
    }
}
