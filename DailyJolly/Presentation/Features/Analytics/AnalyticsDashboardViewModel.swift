import Foundation
import Observation
import SwiftData

struct RecipeVarianceResult: Identifiable {
    var id: String { "\(recipe.persistentModelID)-\(measurementType.rawValue)" }
    let recipe: RecipeEntity
    let measurementType: MeasurementType
    let values: [Double]
    let average: Double
    let min: Double
    let max: Double
    
    // Simple variance (range)
    var range: Double { max - min }
}

@Observable
@MainActor
final class AnalyticsDashboardViewModel {
    
    var isLoading = false
    var overallComplianceScore: Double = 0.0 // 0.0 to 1.0
    var varianceResults: [RecipeVarianceResult] = []
    
    private var repository: ManufacturingRepository?
    
    func setup(modelContext: ModelContext) {
        self.repository = ManufacturingRepository(modelContext: modelContext)
        loadAnalytics()
    }
    
    func loadAnalytics() {
        guard let repository else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        switch repository.fetchAll() {
        case .success(let items):
            calculateCompliance(items: items.filter { $0.isCompleted })
            calculateVariance(items: items.filter { $0.isCompleted })
        case .failure(let error):
            print("[Analytics] Failed to load manufacturing items: \(error)")
        }
    }
    
    private func calculateCompliance(items: [ManufacturingEntity]) {
        guard !items.isEmpty else {
            overallComplianceScore = 0.0
            return
        }
        
        var totalStepsWithRequiredQC = 0
        var totalStepsWithCompletedQC = 0
        
        for batch in items {
            let sortedSteps = batch.recipe.sortedSteps
            for (index, step) in sortedSteps.enumerated() {
                if !step.requiredMeasurements.isEmpty {
                    totalStepsWithRequiredQC += 1
                    if batch.hasRequiredMeasurements(at: index) {
                        totalStepsWithCompletedQC += 1
                    }
                }
            }
        }
        
        if totalStepsWithRequiredQC > 0 {
            overallComplianceScore = Double(totalStepsWithCompletedQC) / Double(totalStepsWithRequiredQC)
        } else {
            overallComplianceScore = 1.0 // If no QC required, compliance is implicitly 100%
        }
    }
    
    private func calculateVariance(items: [ManufacturingEntity]) {
        // Group by recipe
        let groupedByRecipe = Dictionary(grouping: items, by: { $0.recipe })
        
        var results: [RecipeVarianceResult] = []
        
        for (recipe, batches) in groupedByRecipe {
            guard batches.count >= 2 else { continue } // Need at least 2 batches to compare
            
            // Collect all measurements for this recipe across batches
            var measurementsByType: [MeasurementType: [Double]] = [:]
            
            for batch in batches {
                for log in batch.measurements {
                    measurementsByType[log.type, default: []].append(log.value)
                }
            }
            
            for (type, values) in measurementsByType {
                guard values.count >= 2 else { continue }
                
                let avg = values.reduce(0, +) / Double(values.count)
                let minVal = values.min() ?? 0
                let maxVal = values.max() ?? 0
                
                results.append(RecipeVarianceResult(
                    recipe: recipe,
                    measurementType: type,
                    values: values,
                    average: avg,
                    min: minVal,
                    max: maxVal
                ))
            }
        }
        
        // Sort by largest variance range
        self.varianceResults = results.sorted(by: { $0.range > $1.range })
    }
}
