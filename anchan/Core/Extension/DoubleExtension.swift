import Foundation

extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(self))
        : String(format: "%.2f", self)
    }
}
