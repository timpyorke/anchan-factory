import SwiftUI

struct TimePickerView: View {
    let title: String
    @Binding var minutes: Int

    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24) { h in
                        Text("\(h) hr").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Minutes", selection: $mins) {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)
            .onChange(of: hours) { _, _ in updateMinutes() }
            .onChange(of: mins) { _, _ in updateMinutes() }
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(formattedTime)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            hours = minutes / 60
            mins = (minutes % 60 / 5) * 5
        }
    }

    private var formattedTime: String {
        if minutes == 0 {
            return "Not set"
        } else if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    private func updateMinutes() {
        minutes = (hours * 60) + mins
    }
}

#Preview {
    Form {
        TimePickerView(title: "Prep Time", minutes: .constant(90))
        TimePickerView(title: "Cook Time", minutes: .constant(0))
    }
}
