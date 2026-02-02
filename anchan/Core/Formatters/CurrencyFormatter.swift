import Foundation

struct CurrencyFormatter {
    static func format(_ value: Double) -> String {
        let formatted = AppNumberFormatter.format(value, decimals: 2)
        return "฿\(formatted)"
    }
}
