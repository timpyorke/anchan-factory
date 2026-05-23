import SwiftUI
import Charts
import SwiftData

struct ManufacturingProcessVisualizer: View {
    let manufacturing: ManufacturingEntity
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("View Mode", selection: $selectedTab) {
                Text("Process Flow").tag(0)
                Text("QC Analytics").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if selectedTab == 0 {
                ProcessFlowchartView(manufacturing: manufacturing)
            } else {
                ProcessAnalyticsView(manufacturing: manufacturing)
            }
        }
        .padding(.vertical)
        .background(.fill.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Process Flowchart

struct ProcessFlowchartView: View {
    let manufacturing: ManufacturingEntity
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                let sortedSteps = manufacturing.recipe.sortedSteps
                ForEach(Array(sortedSteps.enumerated()), id: \.element.persistentModelID) { index, step in
                    flowNode(step, index: index)
                    
                    if index < sortedSteps.count - 1 {
                        flowArrow
                    }
                }
            }
            .padding()
        }
    }
    
    private func flowNode(_ step: RecipeStepEntity, index: Int) -> some View {
        let isCompleted = manufacturing.isStepCompleted(at: index)
        let isCurrent = !isCompleted && manufacturing.currentStepIndex == index
        
        return VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? Color.green.opacity(0.1) : (isCurrent ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05)))
                    .frame(width: 140, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? Color.green : (isCurrent ? Color.accentColor : Color.secondary.opacity(0.3)), lineWidth: 2)
                    )
                
                VStack(spacing: 4) {
                    Text(step.title)
                        .font(.caption.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                        .foregroundStyle(isCompleted ? .green : (isCurrent ? Color.accentColor : .primary))
                    
                    if isCompleted {
                        let duration = manufacturing.stepDuration(at: index)
                        Text(TimeFormatter.formatDuration(duration))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.green)
                    } else if isCurrent {
                        Text("In Progress")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Text("\(step.time) min")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Dependencies (Simplified for linear flow visualization, but can be enhanced)
            if !step.dependencies.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 8))
                    Text("\(step.dependencies.count) deps")
                        .font(.system(size: 8))
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    private var flowArrow: some View {
        Image(systemName: "arrow.right")
            .font(.title3.bold())
            .foregroundStyle(.secondary.opacity(0.5))
    }
}

// MARK: - Process Analytics

struct ProcessAnalyticsView: View {
    let manufacturing: ManufacturingEntity
    
    var body: some View {
        VStack(spacing: 24) {
            if manufacturing.measurements.isEmpty {
                ContentUnavailableView("No QC Data", systemImage: "chart.bar", description: Text("Complete steps and log measurements to see charts."))
                    .scaleEffect(0.8)
                    .frame(height: 200)
            } else {
                let types = Array(Set(manufacturing.measurements.map { $0.type })).sorted(by: { $0.rawValue < $1.rawValue })
                
                ForEach(types) { type in
                    VStack(alignment: .leading, spacing: 8) {
                        Label(type.rawValue, systemImage: type.icon)
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)
                        
                        let measurements = manufacturing.measurements
                            .filter { $0.type == type }
                            .sorted(by: { $0.stepIndex < $1.stepIndex })
                        
                        Chart {
                            ForEach(measurements) { measurement in
                                LineMark(
                                    x: .value("Step", "Step \(measurement.stepIndex + 1)"),
                                    y: .value(type.rawValue, measurement.value)
                                )
                                .foregroundStyle(by: .value("Type", type.rawValue))
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Step", "Step \(measurement.stepIndex + 1)"),
                                    y: .value(type.rawValue, measurement.value)
                                )
                                .foregroundStyle(by: .value("Type", type.rawValue))
                                .annotation(position: .top) {
                                    Text("\(AppNumberFormatter.format(measurement.value))\(type.symbol)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartLegend(.hidden)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 180)
                    }
                    .padding()
                    .background(.fill.quinary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Duration Analysis
            VStack(alignment: .leading, spacing: 8) {
                Label("Step Durations", systemImage: "stopwatch")
                    .font(.headline)
                
                let completedIndices = manufacturing.completedStepIndices.sorted()
                
                Chart {
                    let sortedSteps = manufacturing.recipe.sortedSteps
                    ForEach(completedIndices, id: \.self) { index in
                        if index >= 0 && index < sortedSteps.count {
                            let duration = manufacturing.stepDuration(at: index)
                            let step = sortedSteps[index]

                            BarMark(
                                x: .value("Step", "Step \(index + 1)"),
                                y: .value("Duration", duration / 60)
                            )
                            .foregroundStyle(duration / 60 > Double(step.time) ? Color.orange : Color.green)
                            .annotation(position: .top) {
                                Text("\(Int(duration / 60))m")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
}
