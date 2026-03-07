import Foundation

struct AppNumberFormatter {
    static func format(_ value: Double, decimals: Int = 2) -> String {
        // If the value is effectively an integer, show without decimals
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        // Otherwise show with specified decimal places
        return String(format: "%.\(decimals)f", value)
    }
}
