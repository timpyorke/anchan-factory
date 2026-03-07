import Foundation

/// Service for generating production templates based on gelling agents.
final class ProductionTemplateService {

    static let shared = ProductionTemplateService()

    private init() {}

    /// Get predefined steps for a specific gelling agent.
    func getSteps(for template: GellingAgentType) -> [RecipeStepInput] {
        switch template {
        case .pectin:
            return [
                RecipeStepInput(title: "Hydrate Pectin", note: "Mix pectin with small amount of sugar", time: 5, requiredMeasurements: [], lineIdentifier: "Line A"),
                RecipeStepInput(title: "Heating Phase", note: "Heat fruit base to 40°C", time: 10, requiredMeasurements: [.temp], lineIdentifier: "Line B"),
                RecipeStepInput(title: "Merge & Boil", note: "Add pectin mix to fruit base, bring to boil", time: 15, requiredMeasurements: [.temp, .ph], lineIdentifier: "Main"),
                RecipeStepInput(title: "Final Check", note: "Measure final Brix and pH", time: 5, requiredMeasurements: [.ph, .brix], lineIdentifier: "Main")
            ]
        case .gelatin:
            return [
                RecipeStepInput(title: "Bloom Gelatin", note: "Soak gelatin in cold water", time: 10, requiredMeasurements: [.temp], lineIdentifier: "Line A"),
                RecipeStepInput(title: "Prepare Base", note: "Heat liquid base to 60°C", time: 10, requiredMeasurements: [.temp], lineIdentifier: "Line B"),
                RecipeStepInput(title: "Combine", note: "Dissolve bloomed gelatin into warm base", time: 5, requiredMeasurements: [.temp], lineIdentifier: "Main"),
                RecipeStepInput(title: "Set Check", note: "Initial pH check before cooling", time: 2, requiredMeasurements: [.ph], lineIdentifier: "Main")
            ]
        case .agar:
            return [
                RecipeStepInput(title: "Disperse Agar", note: "Add agar to cold liquid", time: 5, requiredMeasurements: [], lineIdentifier: "Main"),
                RecipeStepInput(title: "Boil Activation", note: "Bring to boil and hold for 2 mins", time: 10, requiredMeasurements: [.temp], lineIdentifier: "Main"),
                RecipeStepInput(title: "Flavor Addition", note: "Cool slightly before adding flavors", time: 5, requiredMeasurements: [.temp, .brix], lineIdentifier: "Main")
            ]
        case .carrageenan:
            return [
                RecipeStepInput(title: "Dry Mix", note: "Mix carrageenan with other powders", time: 5, requiredMeasurements: [], lineIdentifier: "Main"),
                RecipeStepInput(title: "Heating", note: "Heat to 85°C to dissolve", time: 15, requiredMeasurements: [.temp], lineIdentifier: "Main"),
                RecipeStepInput(title: "pH Stabilization", note: "Verify pH for gel strength", time: 5, requiredMeasurements: [.ph], lineIdentifier: "Main")
            ]
        case .starch:
            return [
                RecipeStepInput(title: "Slurry Prep", note: "Mix starch with cold water", time: 5, requiredMeasurements: [], lineIdentifier: "Main"),
                RecipeStepInput(title: "Gelatinization", note: "Heat until thickened and translucent", time: 12, requiredMeasurements: [.temp], lineIdentifier: "Main"),
                RecipeStepInput(title: "Standardization", note: "Check Brix and pH", time: 5, requiredMeasurements: [.brix, .ph], lineIdentifier: "Main")
            ]
        }
    }
}
