import SwiftUI

struct TimePickerView: View {
    let title: String
    @Binding var seconds: Int

    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
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
                    ForEach(0..<60) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Seconds", selection: $secs) {
                    ForEach(0..<60) { s in
                        Text("\(s) sec").tag(s)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)
            .onChange(of: hours) { _, _ in updateSeconds() }
            .onChange(of: mins) { _, _ in updateSeconds() }
            .onChange(of: secs) { _, _ in updateSeconds() }
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(formattedTime)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            hours = seconds / 3600
            mins = (seconds % 3600) / 60
            secs = seconds % 60
        }
    }

    private var formattedTime: String {
        if seconds == 0 {
            return String(localized: "Not set")
        }
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }

    private func updateSeconds() {
        seconds = (hours * 3600) + (mins * 60) + secs
    }
}

#Preview {
    Form {
        TimePickerView(title: "Prep Time", seconds: .constant(5400))
        TimePickerView(title: "Cook Time", seconds: .constant(0))
        TimePickerView(title: "Step Time", seconds: .constant(90))
    }
}
