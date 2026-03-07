import Foundation

struct StringUtilities {
    /// Trim whitespace and newlines from a string
    static func trimmed(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if a string is valid (non-empty after trimming)
    static func isValidNonEmpty(_ string: String) -> Bool {
        return !trimmed(string).isEmpty
    }
}
