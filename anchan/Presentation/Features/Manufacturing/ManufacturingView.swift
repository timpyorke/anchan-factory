import SwiftUI
import SwiftData

struct ManufacturingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier

    @State private var manufacturing: ManufacturingEntity?
    @State private var showCancelAlert = false
    @State private var showCompletionAlert = false

    var body: some View {
        Group {
            if let manufacturing {
                if manufacturing.isCompleted {
                    completedView(manufacturing)
                } else {
                    stepView(manufacturing)
                }
            } else {
                ContentUnavailableView("Not Found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(manufacturing?.recipe.name ?? "Manufacturing")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if manufacturing?.isCompleted == false {
                    Button("Cancel") {
                        showCancelAlert = true
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                if manufacturing?.isCompleted == true {
                    Button("Done") {
                        stackRouter.pop()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Cancel Manufacturing", isPresented: $showCancelAlert) {
            Button("Continue", role: .cancel) { }
            Button("Cancel", role: .destructive) {
                cancelManufacturing()
            }
        } message: {
            Text("Are you sure you want to cancel this manufacturing process?")
        }
        .alert("Manufacturing Complete!", isPresented: $showCompletionAlert) {
            Button("OK") {
                stackRouter.pop()
            }
        } message: {
            Text("All steps have been completed successfully.")
        }
        .onAppear {
            loadManufacturing()
        }
    }

    // MARK: - Step View

    private func stepView(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 0) {
            // Progress Header
            progressHeader(manufacturing)

            Divider()

            // Current Step
            if let currentStep = manufacturing.currentStep {
                currentStepCard(currentStep, manufacturing: manufacturing)
            }

            Spacer()

            // Complete Step Button
            completeButton(manufacturing)
        }
    }

    private func progressHeader(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 12) {
            // Batch Number
            HStack {
                Text("Batch")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("#\(manufacturing.batchNumber)")
                    .font(.subheadline.bold().monospaced())
                    .foregroundStyle(Color.accentColor)

                Spacer()

                if manufacturing.recipe.totalTime > 0 {
                    Label(manufacturing.recipe.totalTime.formattedTime, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.fill.tertiary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * manufacturing.progress, height: 8)
                        .animation(.easeInOut, value: manufacturing.progress)
                }
            }
            .frame(height: 8)

            // Step Counter
            HStack {
                Text("Step \(manufacturing.currentStepIndex + 1) of \(manufacturing.totalSteps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
    }

    private func currentStepCard(_ step: RecipeStepEntity, manufacturing: ManufacturingEntity) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Step Number Badge
                HStack {
                    Text("Step \(manufacturing.currentStepIndex + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .clipShape(Capsule())

                    Spacer()

                    if step.time > 0 {
                        Label(step.time.formattedTime, systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Step Title
                Text(step.title)
                    .font(.title2.bold())

                // Step Description
                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                // Ingredients for this recipe (show on first step)
                if manufacturing.currentStepIndex == 0 && !manufacturing.recipe.ingredients.isEmpty {
                    ingredientsCard(manufacturing.recipe)
                }
            }
            .padding()
        }
    }

    private func ingredientsCard(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients Needed")
                    .font(.headline)

                Spacer()

                if !recipe.hasEnoughInventory {
                    Label("\(recipe.insufficientCount) low", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recipe.ingredients), id: \.persistentModelID) { ingredient in
                    ingredientRow(ingredient)
                }
            }
        }
        .padding()
        .background(.fill.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func ingredientRow(_ ingredient: IngredientEntity) -> some View {
        let hasStock = ingredient.hasEnoughStock
        return HStack {
            Image(systemName: hasStock ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundStyle(hasStock ? Color.green : Color.orange)

            Text(ingredient.inventoryItem.name)
                .foregroundStyle(hasStock ? Color.primary : Color.orange)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(ingredient.quantity.clean) \(ingredient.unit.symbol)")
                    .foregroundStyle(.secondary)

                if !hasStock {
                    Text("Stock: \(ingredient.inventoryItem.stock.clean) \(ingredient.inventoryItem.baseUnit.symbol)")
                        .font(.caption2)
                        .foregroundStyle(Color.orange)
                }
            }
        }
    }

    private func completeButton(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 16) {
            Divider()

            Button {
                completeCurrentStep(manufacturing)
            } label: {
                HStack {
                    if manufacturing.currentStepIndex + 1 >= manufacturing.totalSteps {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Manufacturing")
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Next Step")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Completed View

    private func completedView(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Manufacturing Complete!")
                    .font(.title.bold())

                Text(manufacturing.recipe.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if let completedAt = manufacturing.completedAt {
                VStack(spacing: 4) {
                    Text("Completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(completedAt, style: .date)
                        .font(.subheadline)

                    Text(completedAt, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Actions

    private func loadManufacturing() {
        manufacturing = modelContext.model(for: id) as? ManufacturingEntity
    }

    private func completeCurrentStep(_ manufacturing: ManufacturingEntity) {
        manufacturing.completeCurrentStep()

        if manufacturing.isCompleted {
            showCompletionAlert = true
        }
    }

    private func cancelManufacturing() {
        if let manufacturing {
            manufacturing.status = .cancelled
        }
        stackRouter.pop()
    }
}

#Preview {
    NavigationStack {
        Text("Manufacturing Preview")
    }
    .modelContainer(AppModelContainer.make())
}
