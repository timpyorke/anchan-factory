import SwiftUI
import SwiftData
import PhotosUI
import Combine

struct ManufacturingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier

    @State private var viewModel = ManufacturingViewModel()
    @State private var stepNote: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showPhotoSourceOptions = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var cameraImage: Data?
    @State private var previewImage: Data?
    @State private var parallelStepNotes: [Int: String] = [:]

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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(imageData: $cameraImage)
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, id: id)
            
            // Initialize notes from existing data
            if let manufacturing = viewModel.manufacturing {
                for log in manufacturing.stepLogs {
                    parallelStepNotes[log.stepIndex] = log.note
                }
            }
        }
        .overlay {
            if let imageData = previewImage, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                previewImage = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: previewImage != nil)
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
                                )
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

                // Timer & Record Section
                HStack(spacing: 16) {
                    let index = manufacturing.currentStepIndex
                    let isStarted = manufacturing.isStepStarted(at: index)
                    let recordedTime = manufacturing.stepCompletionTime(at: index)
                    
                    if !isStarted {
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
                    } else if let recordedTime = recordedTime {
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
            let isTimeRecorded = manufacturing.stepCompletionTime(at: manufacturing.currentStepIndex) != nil
            let canComplete = hasQC && isTimeRecorded

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
                let message = !isTimeRecorded ? String(localized: "Please record the completion time") : String(localized: "Please enter all required measurements")
                Text(message)
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

                // Photo Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "Work Result Photo"))
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 12) {
                            ForEach(manufacturing.images.sorted(by: { $0.createdAt < $1.createdAt })) { imageEntity in
                                if let uiImage = UIImage(data: imageEntity.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            previewImage = imageEntity.imageData
                                        }
                                        .overlay(alignment: .topTrailing) {
                                            Button {
                                                viewModel.removeImage(imageEntity)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, .red)
                                                    .font(.title2)
                                            }
                                            .padding(4)
                                        }
                                }
                            }
                            
                            Menu {
                                #if !targetEnvironment(simulator)
                                Button {
                                    showCamera = true
                                } label: {
                                    Label(String(localized: "Take Photo"), systemImage: "camera")
                                }
                                #endif
                                
                                Button {
                                    showPhotoLibrary = true
                                } label: {
                                    Label(String(localized: "Choose from Library"), systemImage: "photo.on.rectangle")
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                    Text(String(localized: "Add Photo"))
                                        .font(.caption)
                                }
                                .frame(width: 150, height: 150)
                                .background(.fill.quinary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhotos, matching: .images)
                .onChange(of: selectedPhotos) { _, newValue in
                    Task {
                        for item in newValue {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                viewModel.addImageData(data)
                            }
                        }
                        selectedPhotos = []
                    }
                }
                .onChange(of: cameraImage) { _, newValue in
                    if let newValue {
                        viewModel.addImageData(newValue)
                        cameraImage = nil
                    }
                }

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

// MARK: - Step Row View (Parallel)

private struct ParallelStepRow: View {
    let index: Int
    let step: RecipeStepEntity
    let manufacturing: ManufacturingEntity
    let viewModel: ManufacturingViewModel
    @Binding var note: String
    
    var isCompleted: Bool { manufacturing.isStepCompleted(at: index) }
    var canComplete: Bool { manufacturing.canCompleteStep(at: index) }
    var isStarted: Bool { manufacturing.isStepStarted(at: index) }
    var recordedTime: Date? { manufacturing.stepCompletionTime(at: index) }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                
                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if isCompleted {
                    if let stepNote = manufacturing.stepNote(at: index) {
                        Text(stepNote)
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(6)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                } else {
                    TextField(String(localized: "Add note..."), text: $note)
                        .font(.caption)
                        .textFieldStyle(.roundedBorder)
                }

                // Timer & Record Section
                if !isCompleted {
                    HStack {
                        if !isStarted {
                            Button {
                                viewModel.startStep(at: index)
                            } label: {
                                Label(String(localized: "Start Timer"), systemImage: "play.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(.green)
                        } else if isCompleted || recordedTime != nil {
                            let duration = manufacturing.stepDuration(at: index)
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text(TimeFormatter.formatDuration(duration))
                            }
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.1))
                            .clipShape(Capsule())
                        } else {
                            StepTimerView(startTime: manufacturing.getStepStartTime(at: index) ?? Date.now)
                            
                            Button {
                                viewModel.recordStepTime(at: index)
                            } label: {
                                Label(String(localized: "Record Time"), systemImage: "stopwatch.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                        }
                    }
                }

                // Measurement inputs
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
                let isTimeRecorded = recordedTime != nil
                
                Button(canComplete ? (hasQC ? (isTimeRecorded ? String(localized: "Complete") : String(localized: "Need Time")) : String(localized: "Need QC")) : String(localized: "Waiting")) {
                    viewModel.completeStep(at: index, note: note)
                }
                .buttonStyle(.bordered)
                .disabled(!canComplete || !hasQC || !isTimeRecorded)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Step Timer Component

struct StepTimerView: View {
    let startTime: Date
    @State private var elapsed: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(formatDuration(elapsed))
            .font(.caption.monospacedDigit())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.fill.tertiary)
            .clipShape(Capsule())
            .onReceive(timer) { _ in
                elapsed = Date.now.timeIntervalSince(startTime)
            }
            .onAppear {
                elapsed = Date.now.timeIntervalSince(startTime)
            }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}


