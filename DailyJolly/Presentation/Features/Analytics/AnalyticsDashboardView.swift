import SwiftUI
import SwiftData

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AnalyticsDashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    complianceSection
                    varianceSection
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "Analytics & QC"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }
    
    // MARK: - Sections
    
    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Process Compliance"))
                .font(.title2.bold())
            
            HStack(spacing: 20) {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.overallComplianceScore)
                        .stroke(complianceColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: viewModel.overallComplianceScore)
                    
                    VStack {
                        Text("\(Int(viewModel.overallComplianceScore * 100))%")
                            .font(.title.bold())
                        Text("Score")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Quality Control Tracking"))
                        .font(.headline)
                    Text(String(localized: "This score represents the percentage of required QC measurements (Temp, pH, Brix, Aw) successfully logged across all completed batches."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var varianceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Batch Variance Analysis"))
                .font(.title2.bold())
            
            Text(String(localized: "Compares QC measurements across multiple batches of the same recipe to identify inconsistency. Lower variance means higher consistency."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if viewModel.varianceResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text(String(localized: "Not enough data. Complete at least two batches of the same recipe with QC measurements to see variance."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ForEach(viewModel.varianceResults) { result in
                    varianceCard(for: result)
                }
            }
        }
    }
    
    private func varianceCard(for result: RecipeVarianceResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(result.recipe.name)
                    .font(.headline)
                Spacer()
                Label(result.measurementType.rawValue, systemImage: result.measurementType.icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }
            
            HStack(spacing: 20) {
                varianceMetric(title: String(localized: "Average"), value: result.average, type: result.measurementType)
                varianceMetric(title: String(localized: "Min"), value: result.min, type: result.measurementType)
                varianceMetric(title: String(localized: "Max"), value: result.max, type: result.measurementType)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(localized: "Variance Range"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("± \(AppNumberFormatter.format(result.range / 2)) \(result.measurementType.symbol)")
                        .font(.headline)
                        .foregroundStyle(result.range > getWarningThreshold(for: result.measurementType) ? .orange : .green)
                }
            }
        }
        .padding()
        .background(.fill.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func varianceMetric(title: String, value: Double, type: MeasurementType) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(AppNumberFormatter.format(value)) \(type.symbol)")
                .font(.subheadline.bold())
        }
    }
    
    private var complianceColor: Color {
        if viewModel.overallComplianceScore >= 0.9 {
            return .green
        } else if viewModel.overallComplianceScore >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Simple mock thresholds for coloring variance
    private func getWarningThreshold(for type: MeasurementType) -> Double {
        switch type {
        case .ph: return 0.5   // e.g. 0.5 pH variance is high
        case .brix: return 2.0 // e.g. 2.0 Brix variance is high
        case .temp: return 5.0 // e.g. 5.0 degree variance is high
        case .aw: return 0.05
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsDashboardView()
    }
    .modelContainer(AppModelContainer.make())
}
