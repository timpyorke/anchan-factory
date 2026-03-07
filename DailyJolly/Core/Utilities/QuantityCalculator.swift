import Foundation

struct QuantityCalculator {
    /// Convert quantity from one unit to another using base unit as intermediary
    static func convert(quantity: Double, from fromUnit: String, to toUnit: String, baseUnit: String, customUnits: [(name: String, ratio: Double)]) -> Double? {
        // If units are the same, no conversion needed
        if fromUnit == toUnit {
            return quantity
        }

        // Convert to base unit first
        let baseQuantity = toBaseUnit(quantity: quantity, unit: fromUnit, baseUnit: baseUnit, customUnits: customUnits)

        // Then convert from base unit to target unit
        return fromBaseUnit(quantity: baseQuantity, unit: toUnit, baseUnit: baseUnit, customUnits: customUnits)
    }

    /// Convert quantity to base unit
    static func toBaseUnit(quantity: Double, unit: String, baseUnit: String, customUnits: [(name: String, ratio: Double)]) -> Double {
        // If already in base unit, return as-is
        if unit == baseUnit {
            return quantity
        }

        // Find custom unit and convert
        if let customUnit = customUnits.first(where: { $0.name == unit }) {
            return quantity * customUnit.ratio
        }

        // If unit not found, assume it's already in base unit
        return quantity
    }

    /// Convert from base unit to target unit
    static func fromBaseUnit(quantity: Double, unit: String, baseUnit: String, customUnits: [(name: String, ratio: Double)]) -> Double {
        // If converting to base unit, return as-is
        if unit == baseUnit {
            return quantity
        }

        // Find custom unit and convert
        if let customUnit = customUnits.first(where: { $0.name == unit }) {
            return quantity / customUnit.ratio
        }

        // If unit not found, return as-is
        return quantity
    }
}
