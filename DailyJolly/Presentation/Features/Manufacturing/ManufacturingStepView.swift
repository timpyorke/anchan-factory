import SwiftUI
import SwiftData
import PhotosUI

struct ManufacturingStepView: View {
    let manufacturing: ManufacturingEntity
    let viewModel: ManufacturingViewModel
    @Binding var stepNote: String
    @Binding var previewImage: Data?
    @Binding var showCamera: Bool
    @Binding var showPhotoLibrary: Bool
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var parallelStepNotes: [Int: String]
    @Binding var currentStepIndexForPhoto: Int?

    var body: some View {
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
                            ParallelStepRow(
                                index: index,
                                step: step,
                                manufacturing: manufacturing,
                                viewModel: viewModel,
                                note: Binding(
                                    get: { parallelStepNotes[index] ?? "" },
                                    set: { 
                                        parallelStepNotes[index] = $0
                                        viewModel.updateStepNote(at: index, note: $0)
                                    }
                                ),
                                previewImage: $previewImage,
                                showCamera: $showCamera,
                                showPhotoLibrary: $showPhotoLibrary,
                                selectedPhotos: $selectedPhotos,
                                currentStepIndexForPhoto: $currentStepIndexForPhoto
                            )
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
                }

                // Step Title
                Text(step.title)
                    .font(.title2.bold())

                // Timer & Record Section
                if step.isTimerRequired {
                    HStack(spacing: 16) {
                        let index = manufacturing.currentStepIndex
                        
                        if !manufacturing.isStepStarted(at: index) {
                            Button {
                                viewModel.startStep(at: index)
                            } label: {
                                Label(String(localized: "Start Timer"), systemImage: "play.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.green)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        } else if manufacturing.stepCompletionTime(at: index) != nil {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "Time Recorded"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                let duration = manufacturing.stepDuration(at: index)
                                Text(TimeFormatter.formatDuration(duration))
                                    .font(.title3.bold())
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button {
                                viewModel.recordStepTime(at: index)
                            } label: {
                                Label(String(localized: "Re-record"), systemImage: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        } else {
                            StepTimerView(startTime: manufacturing.getStepStartTime(at: index) ?? Date.now)
                                .scaleEffect(1.2)
                            
                            Button {
                                viewModel.recordStepTime(at: index)
                            } label: {
                                Label(String(localized: "Record Time"), systemImage: "stopwatch.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.orange)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }

                // Step Description
                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                // Step Photos
                StepPhotoSection(
                    index: manufacturing.currentStepIndex,
                    manufacturing: manufacturing,
                    viewModel: viewModel,
                    previewImage: $previewImage,
                    showCamera: $showCamera,
                    showPhotoLibrary: $showPhotoLibrary,
                    selectedPhotos: $selectedPhotos,
                    currentStepIndexForPhoto: $currentStepIndexForPhoto
                )

                // Step Note Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Note (Optional)"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField(String(localized: "Add a note for this step..."), text: Binding(
                        get: { stepNote },
                        set: {
                            stepNote = $0
                            viewModel.updateStepNote(at: manufacturing.currentStepIndex, note: $0)
                        }
                    ), axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.top, 8)
                .task(id: manufacturing.currentStepIndex) {
                    // Update the local state when step changes
                    stepNote = manufacturing.getStepNote(at: manufacturing.currentStepIndex)
                }

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

            let hasQC = manufacturing.hasRequiredMeasurements(at: manufacturing.currentStepIndex)
            let isTimerRequired = manufacturing.currentStep?.isTimerRequired ?? false
            let isTimeRecorded = manufacturing.stepCompletionTime(at: manufacturing.currentStepIndex) != nil
            let canComplete = hasQC && (!isTimerRequired || isTimeRecorded)

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
                let message = (isTimerRequired && !isTimeRecorded) ? String(localized: "Please record the completion time") : String(localized: "Please enter all required measurements")
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.bottom, 8)
            }
        }
    }
}
