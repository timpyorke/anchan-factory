import SwiftUI
import SwiftData

struct ManufacturingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier

    @State private var viewModel = ManufacturingViewModel()
    @State private var stepNote: String = ""

    var body: some View {
        Group {
            if let manufacturing = viewModel.manufacturing {
                if manufacturing.isCompleted {
                    completedView(manufacturing)
                } else {
                    stepView(manufacturing)
                }
            } else {
                ContentUnavailableView(String(localized: "Not Found"), systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(viewModel.manufacturing?.recipe.name ?? String(localized: "Manufacturing"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if viewModel.manufacturing?.isCompleted == false {
                    Button {
                        viewModel.showExitOptions = true
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                if viewModel.manufacturing?.isCompleted == true {
                    Button(String(localized: "Done")) {
                        stackRouter.pop()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .confirmationDialog(String(localized: "Exit Manufacturing"), isPresented: $viewModel.showExitOptions, titleVisibility: .visible) {
            Button(String(localized: "Save & Exit")) {
                stackRouter.pop()
            }
            Button(String(localized: "Cancel Manufacturing"), role: .destructive) {
                viewModel.showCancelAlert = true
            }
            Button(String(localized: "Keep Working"), role: .cancel) { }
        } message: {
            Text(String(localized: "Your progress is automatically saved. You can continue later."))
        }
        .alert(String(localized: "Cancel Manufacturing"), isPresented: $viewModel.showCancelAlert) {
            Button(String(localized: "Go Back"), role: .cancel) { }
            Button(String(localized: "Cancel Manufacturing"), role: .destructive) {
                viewModel.cancelManufacturing {
                    stackRouter.pop()
                }
            }
        } message: {
            Text(String(localized: "Are you sure you want to cancel? This will mark the batch as cancelled and cannot be undone."))
        }
        .alert(String(localized: "Manufacturing Complete!"), isPresented: $viewModel.showCompletionAlert) {
            Button(String(localized: "OK")) {
                stackRouter.pop()
            }
        } message: {
            Text(String(localized: "All steps have been completed successfully."))
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, id: id)
        }
    }

    // MARK: - Step View

    private func stepView(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 0) {
            // Progress Header
            progressHeader(manufacturing)

            Divider()

            let steps = manufacturing.recipe.sortedSteps
            let hasParallelLines = steps.contains { $0.lineIdentifier != nil }

            if hasParallelLines {
                parallelLinesList(manufacturing)
            } else {
                // Current Step
                if let currentStep = manufacturing.currentStep {
                    currentStepCard(currentStep, manufacturing: manufacturing)
                }

                Spacer()

                // Complete Step Button
                completeButton(manufacturing)
            }
        }
    }

    private func parallelLinesList(_ manufacturing: ManufacturingEntity) -> some View {
        List {
            let sortedSteps = manufacturing.recipe.sortedSteps
            let lines = Array(Set(sortedSteps.compactMap { $0.lineIdentifier } + ["Main"])).sorted()

            ForEach(lines, id: \.self) { line in
                Section(header: Text(line)) {
                    ForEach(Array(sortedSteps.enumerated()), id: \.offset) { index, step in
                        if (step.lineIdentifier ?? "Main") == line {
                            let isCompleted = manufacturing.isStepCompleted(at: index)
                            let canComplete = manufacturing.canCompleteStep(at: index)

                            HStack {
                                VStack(alignment: .leading) {
                                    Text(step.title)
                                        .font(.headline)
                                        .foregroundStyle(isCompleted ? .secondary : .primary)
                                    if !step.note.isEmpty {
                                        Text(step.note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    // Measurement inputs for parallel view
                                    if !isCompleted && !step.requiredMeasurements.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            ForEach(step.requiredMeasurements) { measurement in
                                                let loggedValue = manufacturing.getMeasurements(at: index)
                                                    .first(where: { $0.type == measurement })?.value
                                                
                                                MeasurementInputView(
                                                    type: measurement,
                                                    value: .constant(loggedValue),
                                                    onSave: { newValue in
                                                        viewModel.logMeasurement(at: index, type: measurement, value: newValue)
                                                    }
                                                )
                                                .scaleEffect(0.8)
                                                .frame(height: 25)
                                            }
                                        }
                                        .padding(.top, 4)
                                    }
                                }

                                Spacer()

                                if isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    let hasQC = manufacturing.hasRequiredMeasurements(at: index)
                                    Button(canComplete ? (hasQC ? String(localized: "Complete") : String(localized: "Need QC")) : String(localized: "Waiting")) {
                                        viewModel.completeStep(at: index)
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(!canComplete || !hasQC)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func progressHeader(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 12) {
            // Batch Number
            HStack {
                Text(String(localized: "Batch"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("#\(manufacturing.batchNumber)")
                    .font(.subheadline.bold().monospaced())
                    .foregroundStyle(Color.accentColor)

                Spacer()

                if manufacturing.recipe.totalTime > 0 {
                    Label(manufacturing.recipe.totalTime.formattedTimeCompact, systemImage: "clock")
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
                Text(String(localized: "Step \(manufacturing.currentStepIndex + 1) of \(manufacturing.totalSteps)"))
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
                    Text(String(localized: "Step") + " \(manufacturing.currentStepIndex + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .clipShape(Capsule())

                    Spacer()

                    if step.time > 0 {
                        Label(step.time.formattedTimeCompact, systemImage: "clock")
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

                // Step Note Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Note (Optional)"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField(String(localized: "Add a note for this step..."), text: $stepNote, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.top, 8)

                // Required Measurements
                if !step.requiredMeasurements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "Required Measurements"))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 12) {
                            ForEach(step.requiredMeasurements) { measurement in
                                let loggedValue = manufacturing.getMeasurements(at: manufacturing.currentStepIndex)
                                    .first(where: { $0.type == measurement })?.value
                                
                                MeasurementInputView(
                                    type: measurement,
                                    value: .constant(loggedValue),
                                    onSave: { newValue in
                                        viewModel.logMeasurement(at: manufacturing.currentStepIndex, type: measurement, value: newValue)
                                    }
                                )
                            }
                        }
                        .padding()
                        .background(.fill.quinary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
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
                Text(String(localized: "Ingredients Needed"))
                    .font(.headline)

                Spacer()

                if !recipe.hasEnoughInventory {
                    Label(String(localized: "\(recipe.insufficientCount) low"), systemImage: "exclamationmark.triangle.fill")
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
                Text("\(AppNumberFormatter.format(ingredient.quantity)) \(ingredient.displaySymbol)")
                    .foregroundStyle(.secondary)

                if !hasStock {
                    Text(String(localized: "Stock: \(AppNumberFormatter.format(ingredient.inventoryItem.stock)) \(ingredient.inventoryItem.displaySymbol)"))
                        .font(.caption2)
                        .foregroundStyle(Color.orange)
                }
            }
        }
    }

    private func completeButton(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(spacing: 16) {
            Divider()

            let canComplete = manufacturing.hasRequiredMeasurements(at: manufacturing.currentStepIndex)

            Button {
                viewModel.completeCurrentStep(note: stepNote)
                stepNote = ""
            } label: {
                HStack {
                    if manufacturing.currentStepIndex + 1 >= manufacturing.totalSteps {
                        Image(systemName: "checkmark.circle.fill")
                        Text(String(localized: "Complete Manufacturing"))
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                        Text(String(localized: "Next Step"))
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canComplete ? Color.accentColor : Color.gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(!canComplete)

            if !canComplete {
                Text(String(localized: "Please enter all required measurements"))
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Completed View

    private func completedView(_ manufacturing: ManufacturingEntity) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)

                VStack(spacing: 8) {
                    Text(String(localized: "Manufacturing Complete!"))
                        .font(.title.bold())

                    Text(manufacturing.recipe.name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                // Flexible Output Section
                VStack(spacing: 12) {
                    Text(String(localized: "Total Units Produced"))
                        .font(.subheadline.bold())
                    
                    HStack {
                        TextField("0", value: Binding(
                            get: { manufacturing.actualOutput ?? Double(manufacturing.totalUnits) },
                            set: { viewModel.updateActualOutput($0) }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.title2.bold())
                        .frame(width: 120)
                        .textFieldStyle(.roundedBorder)
                        
                        Text(manufacturing.recipe.batchUnit)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(String(localized: "Expected: \(manufacturing.totalUnits) \(manufacturing.recipe.batchUnit)"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Completed Measurements Summary
                if !manufacturing.measurements.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Quality Control Log"))
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        let sortedMeasurements = manufacturing.measurements.sorted(by: { $0.timestamp < $1.timestamp })
                        let steps = manufacturing.recipe.sortedSteps
                        
                        ForEach(sortedMeasurements) { log in
                            let stepTitle = log.stepIndex < steps.count ? steps[log.stepIndex].title : "Step \(log.stepIndex + 1)"
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stepTitle).font(.caption).foregroundStyle(.secondary)
                                    Text(log.type.rawValue).font(.subheadline)
                                }
                                Spacer()
                                Text("\(AppNumberFormatter.format(log.value)) \(log.type.symbol)")
                                    .font(.headline)
                            }
                            Divider()
                        }
                    }
                    .padding()
                    .background(.fill.quinary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                if let completedAt = manufacturing.completedAt {
                    VStack(spacing: 4) {
                        Text(String(localized: "Completed"))
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
    }

    // MARK: - Actions

}

#Preview {
    NavigationStack {
        Text("Manufacturing Preview")
    }
    .modelContainer(AppModelContainer.make())
}
