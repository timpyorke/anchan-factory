import Foundation

extension Double {
    @available(*, deprecated, message: "Use AppNumberFormatter.format() instead")
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(self))
        : String(format: "%.2f", self)
    }
}
