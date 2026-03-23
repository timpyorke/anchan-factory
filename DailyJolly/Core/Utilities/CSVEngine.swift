import Foundation

/// Shared utility for CSV parsing and formatting.
final class CSVEngine {
    
    static let shared = CSVEngine()
    private init() {}
    
    /// Parse a CSV string into rows and columns
    func parse(_ data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: .newlines)
        
        for row in rows {
            if row.isEmpty { continue }
            
            var columns: [String] = []
            var currentColumn = ""
            var insideQuotes = false
            
            let characters = Array(row)
            var i = 0
            while i < characters.count {
                let char = characters[i]
                
                if char == "\"" {
                    if insideQuotes && i + 1 < characters.count && characters[i+1] == "\"" {
                        currentColumn.append("\"")
                        i += 1
                    } else {
                        insideQuotes.toggle()
                    }
                } else if char == "," && !insideQuotes {
                    columns.append(currentColumn)
                    currentColumn = ""
                } else {
                    currentColumn.append(char)
                }
                i += 1
            }
            columns.append(currentColumn)
            result.append(columns)
        }
        
        return result
    }
    
    /// Format a row of values into a CSV line
    func formatRow(_ values: [String]) -> String {
        values.map { escape($0) }.joined(separator: ",")
    }
    
    /// Escape a single value for CSV
    func escape(_ text: String) -> String {
        var escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            escaped = "\"\(escaped)\""
        }
        return escaped
    }
}
