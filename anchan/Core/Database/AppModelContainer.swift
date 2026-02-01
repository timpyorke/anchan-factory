import SwiftData

enum AppModelContainer {

    static func make() -> ModelContainer {
        let schema = Schema([
            RecipeEntity.self,
            RecipeStepEntity.self,
            InventoryEntity.self,
            IngredientEntity.self,
            ManufacturingEntity.self,
            CustomUnitEntity.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        return try! ModelContainer(
            for: schema,
            configurations: [config]
        )
    }
}
