import Foundation

struct TimeFormatter {
    /// Format minutes into human-readable format (e.g., "1h 30m", "45m")
    static func formatMinutes(_ minutes: Int) -> String {
        guard minutes > 0 else { return "0m" }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    /// Format time interval (seconds) into human-readable duration (e.g., "2h 15m", "45m")
    static func formatDuration(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval / 60)
        return formatMinutes(totalMinutes)
    }
}
