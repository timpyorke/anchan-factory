import Foundation

extension Int {
    /// Formats minutes into a readable time string
    /// e.g., 90 -> "1h 30m", 45 -> "45m", 120 -> "2h"
    var formattedTime: String {
        if self == 0 {
            return "0m"
        }

        let hours = self / 60
        let mins = self % 60

        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}
