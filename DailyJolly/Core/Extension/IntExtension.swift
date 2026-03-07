import Foundation

extension Int {
    /// Format seconds as hh:mm:ss
    var formattedTime: String {
        TimeFormatter.formatSeconds(self)
    }

    /// Format seconds as compact time (e.g., "1h 30m 15s")
    var formattedTimeCompact: String {
        TimeFormatter.formatSecondsCompact(self)
    }
}
