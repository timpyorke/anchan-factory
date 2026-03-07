import Foundation

/// Represents the types of quality control measurements that can be taken during production.
enum MeasurementType: String, Codable, CaseIterable, Identifiable {
    case temp = "Temperature"
    case ph = "pH"
    case brix = "Brix"
    case aw = "Aw"

    var id: String { self.rawValue }

    var symbol: String {
        switch self {
        case .temp: return "°C"
        case .ph: return "pH"
        case .brix: return "°Bx"
        case .aw: return "aw"
        }
    }

    var icon: String {
        switch self {
        case .temp: return "thermometer.medium"
        case .ph: return "drop.fill"
        case .brix: return "speedometer"
        case .aw: return "water.waves"
        }
    }
}
