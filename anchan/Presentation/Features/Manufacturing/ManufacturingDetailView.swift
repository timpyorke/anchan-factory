import SwiftUI
import SwiftData

struct ManufacturingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier

    @State private var manufacturing: ManufacturingEntity?
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if let manufacturing {
                contentView(manufacturing)
            } else {
                ContentUnavailableView("Not Found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(manufacturing?.recipe.name ?? "Manufacturing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Manufacturing", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteManufacturing()
            }
        } message: {
            Text("Are you sure you want to delete this manufacturing record?")
        }
        .onAppear {
            loadManufacturing()
        }
    }

    // MARK: - Content

    private func contentView(_ manufacturing: ManufacturingEntity) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Summary Header
                summaryHeader(manufacturing)

                // Time Summary
                if !manufacturing.recipe.steps.isEmpty {
                    timeSummary(manufacturing)
                }

                // Steps List
                if !manufacturing.recipe.steps.isEmpty {
                    stepsSection(manufacturing)
                }

                // Ingredients Used
                if !manufacturing.recipe.ingredients.isEmpty {
                    ingredientsSection(manufacturing.recipe)
                }
            }
            .padding()
        }
    }

    private func summaryHeader(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Batch Number Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Batch Number")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("#\(manufacturing.batchNumber)")
                        .font(.title2.bold().monospaced())
                        .foregroundStyle(Color.accentColor)
                }

                Spacer()

                Image(systemName: manufacturing.isCompleted ? "checkmark.circle.fill" : "clock.fill")
                    .foregroundStyle(manufacturing.isCompleted ? .green : .orange)
                    .font(.title)
            }

            Divider()

            HStack {
                Text(manufacturing.isCompleted ? "Completed" : "In Progress")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(manufacturing.isCompleted ? .green : .orange)

                Spacer()

                if let category = manufacturing.recipe.category {
                    Text(category)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.fill.tertiary)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                Label {
                    Text("Started: \(manufacturing.startedAt, format: .dateTime.month().day().hour().minute())")
                } icon: {
                    Image(systemName: "play.circle")
                }

                if let completedAt = manufacturing.completedAt {
                    Label {
                        Text("Ended: \(completedAt, format: .dateTime.hour().minute())")
                    } icon: {
                        Image(systemName: "stop.circle")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            // Batch & Cost Info
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Batches")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(manufacturing.quantity)x")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Units")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(manufacturing.totalUnits) \(manufacturing.recipe.batchUnit)")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Cost")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("฿\(manufacturing.totalCost.clean)")
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Per Unit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("฿\(manufacturing.costPerUnit.clean)")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.fill.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func timeSummary(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Summary")
                .font(.title3.bold())

            HStack(spacing: 16) {
                // Total Duration
                VStack(spacing: 4) {
                    Text(formatDuration(manufacturing.totalDuration))
                        .font(.title2.bold())
                        .foregroundStyle(Color.accentColor)
                    Text("Total Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Estimated vs Actual
                VStack(spacing: 4) {
                    let estimated = manufacturing.recipe.totalTime
                    Text("\(estimated)m")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                    Text("Estimated")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Steps Count
                VStack(spacing: 4) {
                    Text("\(manufacturing.totalSteps)")
                        .font(.title2.bold())
                    Text("Steps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func stepsSection(_ manufacturing: ManufacturingEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps")
                .font(.title3.bold())

            VStack(spacing: 0) {
                ForEach(Array(manufacturing.recipe.sortedSteps.enumerated()), id: \.element.persistentModelID) { index, step in
                    stepRow(step, index: index, manufacturing: manufacturing)

                    if index < manufacturing.recipe.steps.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func stepRow(_ step: RecipeStepEntity, index: Int, manufacturing: ManufacturingEntity) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Step Number
            let isCompleted = index < manufacturing.stepCompletionTimes.count
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.secondary.opacity(0.3))
                    .frame(width: 32, height: 32)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                // Step Title
                Text(step.title)
                    .font(.headline)

                // Step Note
                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Time Info
                HStack(spacing: 16) {
                    // Estimated time
                    if step.time > 0 {
                        Label("Est: \(step.time)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Actual duration
                    if isCompleted {
                        let duration = manufacturing.stepDuration(at: index)
                        Label("Actual: \(formatDuration(duration))", systemImage: "stopwatch")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                // Completion time
                if let completionTime = manufacturing.stepCompletionTime(at: index) {
                    Text("Completed at \(completionTime, format: .dateTime.hour().minute().second())")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func ingredientsSection(_ recipe: RecipeEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients Used")
                    .font(.title3.bold())

                Spacer()

                if recipe.totalCost > 0 {
                    Text("฿\(recipe.totalCost.clean)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipe.ingredients, id: \.persistentModelID) { ingredient in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.secondary)

                        Text(ingredient.inventoryItem.name)

                        Spacer()

                        Text("\(ingredient.quantity.clean) \(ingredient.unit.symbol)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    // MARK: - Actions

    private func loadManufacturing() {
        manufacturing = modelContext.model(for: id) as? ManufacturingEntity
    }

    private func deleteManufacturing() {
        if let manufacturing {
            modelContext.delete(manufacturing)
        }
        stackRouter.pop()
    }
}

#Preview {
    NavigationStack {
        Text("Manufacturing Detail Preview")
    }
    .modelContainer(AppModelContainer.make())
}
