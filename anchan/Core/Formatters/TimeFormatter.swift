import Foundation

struct TimeFormatter {
    /// Format seconds into hh:mm:ss format (e.g., "01:30:00", "00:45:30")
    static func formatSeconds(_ totalSeconds: Int) -> String {
        guard totalSeconds > 0 else { return "00:00:00" }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Format seconds into compact human-readable format (e.g., "1h 30m 15s", "45m 30s")
    static func formatSecondsCompact(_ totalSeconds: Int) -> String {
        guard totalSeconds > 0 else { return "0s" }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var parts: [String] = []
        if hours > 0 { parts.append("\(hours)h") }
        if minutes > 0 { parts.append("\(minutes)m") }
        if seconds > 0 || parts.isEmpty { parts.append("\(seconds)s") }

        return parts.joined(separator: " ")
    }

    /// Format minutes into human-readable format (e.g., "1h 30m", "45m")
    /// @deprecated Use formatSeconds or formatSecondsCompact instead
    static func formatMinutes(_ minutes: Int) -> String {
        return formatSecondsCompact(minutes * 60)
    }

    /// Format time interval (seconds) into human-readable duration
    static func formatDuration(_ interval: TimeInterval) -> String {
        return formatSecondsCompact(Int(interval))
    }
}
