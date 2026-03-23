import Foundation
import SwiftData

@MainActor
final class CSVImportService {
    static let shared = CSVImportService()
    
    private init() {}
    
    /// Import inventory from CSV
    func importInventory(from url: URL, modelContext: ModelContext) -> Result<Int, AppError> {
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = parseCSV(data)
            
            guard rows.count > 1 else { return .success(0) }
            
            let headers = rows[0].map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
            var importCount = 0
            
            for i in 1..<rows.count {
                let row = rows[i]
                guard row.count >= headers.count else { continue }
                
                var name = ""
                var category: String?
                var unitSymbol = "g"
                var stock: Double = 0
                var minStock: Double = 0
                var unitPrice: Double = 0
                var phValue: Double?
                
                for (index, header) in headers.enumerated() {
                    let value = row[index].trimmingCharacters(in: .whitespaces)
                    
                    switch header {
                    case "name": name = value
                    case "category": category = value.isEmpty || value == "-" ? nil : value
                    case "unit": unitSymbol = value
                    case "stock": stock = Double(value) ?? 0
                    case "min stock": minStock = Double(value) ?? 0
                    case "unit price", "price": 
                        // Strip currency symbol if present
                        let cleanPrice = value.replacingOccurrences(of: "฿", with: "").replacingOccurrences(of: ",", with: "")
                        unitPrice = Double(cleanPrice) ?? 0
                    case "ph": phValue = Double(value)
                    default: break
                    }
                }
                
                if !name.isEmpty {
                    let item = InventoryEntity(
                        name: name,
                        category: category,
                        unitSymbol: unitSymbol,
                        unitPrice: unitPrice,
                        stock: stock,
                        minStock: minStock,
                        phValue: phValue
                    )
                    modelContext.insert(item)
                    importCount += 1
                }
            }
            
            try modelContext.save()
            return .success(importCount)
            
        } catch {
            return .failure(.databaseError("Import failed: \(error.localizedDescription)"))
        }
    }
    
    /// Import recipes from CSV (Basic info only)
    func importRecipes(from url: URL, modelContext: ModelContext) -> Result<Int, AppError> {
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = parseCSV(data)
            
            guard rows.count > 1 else { return .success(0) }
            
            let headers = rows[0].map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
            var importCount = 0
            
            for i in 1..<rows.count {
                let row = rows[i]
                guard row.count >= headers.count else { continue }
                
                var name = ""
                var category: String?
                var batchSize = 1
                var batchUnit = "pcs"
                
                for (index, header) in headers.enumerated() {
                    let value = row[index].trimmingCharacters(in: .whitespaces)
                    
                    switch header {
                    case "name": name = value
                    case "category": category = value.isEmpty || value == "-" ? nil : value
                    case "batch size": batchSize = Int(value) ?? 1
                    case "batch unit": batchUnit = value
                    default: break
                    }
                }
                
                if !name.isEmpty {
                    let recipe = RecipeEntity(
                        name: name,
                        category: category,
                        batchSize: batchSize,
                        batchUnit: batchUnit
                    )
                    modelContext.insert(recipe)
                    importCount += 1
                }
            }
            
            try modelContext.save()
            return .success(importCount)
            
        } catch {
            return .failure(.databaseError("Import failed: \(error.localizedDescription)"))
        }
    }
    
    private func parseCSV(_ data: String) -> [[String]] {
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
}
