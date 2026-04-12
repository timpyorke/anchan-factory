import SwiftUI
import SwiftData

struct ManufacturingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter
    
    @Query(sort: \ManufacturingEntity.startedAt, order: .reverse) private var allManufacturing: [ManufacturingEntity]

    @State private var viewModel = ManufacturingListViewModel()

    var body: some View {
        Group {
            if allManufacturing.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .navigationTitle(String(localized: "Manufacturing History"))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: String(localized: "Search by recipe or batch number"))
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }

    // MARK: - List Content

    private var listContent: some View {
        let filteredManufacturing = allManufacturing.filter { item in
            let matchesStatus: Bool
            switch viewModel.selectedFilter {
            case .all: matchesStatus = true
            case .active: matchesStatus = item.status == .inProgress
            case .completed: matchesStatus = item.status == .completed
            case .cancelled: matchesStatus = item.status == .cancelled
            }
            
            let matchesSearch = viewModel.searchText.isEmpty || 
                item.recipe.name.localizedCaseInsensitiveContains(viewModel.searchText) ||
                item.batchNumber.localizedCaseInsensitiveContains(viewModel.searchText)
            
            return matchesStatus && matchesSearch
        }
        
        return VStack(spacing: 0) {
            // Filter Picker
            filterPicker
                .padding(.horizontal)
                .padding(.vertical, 8)

            Divider()

            // List
            List {
                ForEach(filteredManufacturing, id: \.persistentModelID) { manufacturing in
                    ManufacturingListRow(manufacturing: manufacturing) {
                        navigateToDetail(manufacturing)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if manufacturing.status != .inProgress {
                            Button(role: .destructive) {
                                modelContext.delete(manufacturing)
                                try? modelContext.save()
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ManufacturingFilter.allCases) { filter in
                    FilterChip(
                        title: filter.title,
                        icon: filter.icon,
                        count: countForFilter(filter),
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
        }
    }

    private func countForFilter(_ filter: ManufacturingFilter) -> Int {
        switch filter {
        case .all:
            return allManufacturing.count
        case .active:
            return allManufacturing.filter { $0.status == .inProgress }.count
        case .completed:
            return allManufacturing.filter { $0.status == .completed }.count
        case .cancelled:
            return allManufacturing.filter { $0.status == .cancelled }.count
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            String(localized: "No Manufacturing Records"),
            systemImage: "shippingbox",
            description: Text(String(localized: "Manufacturing batches will appear here"))
        )
    }

    // MARK: - Navigation

    private func navigateToDetail(_ manufacturing: ManufacturingEntity) {
        if manufacturing.status == .inProgress {
            stackRouter.push(.manufacturingProcess(id: manufacturing.persistentModelID))
        } else {
            stackRouter.push(.manufacturingDetail(id: manufacturing.persistentModelID))
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.subheadline.weight(.medium))

                if count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? .white.opacity(0.3) : .secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Manufacturing List Row

private struct ManufacturingListRow: View {
    let manufacturing: ManufacturingEntity
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status Icon
                statusIcon

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(manufacturing.recipe.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("#\(manufacturing.batchNumber)")
                            .font(.caption.monospaced())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        // Quantity
                        Label("\(manufacturing.quantity)x", systemImage: "number")

                        // Total units
                        Label("\(manufacturing.totalUnits) \(manufacturing.recipe.batchUnit)", systemImage: "shippingbox")

                        // Cost
                        if manufacturing.totalCost > 0 {
                            Label(CurrencyFormatter.format(manufacturing.totalCost), systemImage: "banknote")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // Date info
                    HStack(spacing: 8) {
                        Text(manufacturing.startedAt, format: .dateTime.month().day().hour().minute())

                        if let completedAt = manufacturing.completedAt {
                            Image(systemName: "arrow.right")
                            Text(completedAt, format: .dateTime.hour().minute())
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                }

                Spacer()

                // Progress or chevron
                if manufacturing.status == .inProgress {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(manufacturing.progress * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.accentColor)

                        Text("Step \(manufacturing.currentStepIndex + 1)/\(manufacturing.totalSteps)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
        }
        .buttonStyle(.row)
    }

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 40, height: 40)

            Image(systemName: statusIconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(statusColor)
        }
    }

    private var statusColor: Color {
        switch manufacturing.status {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }

    private var statusIconName: String {
        switch manufacturing.status {
        case .pending:
            return "clock"
        case .inProgress:
            return "play.fill"
        case .completed:
            return "checkmark"
        case .cancelled:
            return "xmark"
        }
    }
}

#Preview {
    NavigationStack {
        ManufacturingListView()
    }
    .environment(StackRouter())
    .modelContainer(AppModelContainer.make())
}
