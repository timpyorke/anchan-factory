import SwiftUI

struct MeasurementInputView: View {
    let type: MeasurementType
    @Binding var value: Double?
    let onSave: (Double) -> Void
    
    @State private var textValue: String = ""
    
    init(type: MeasurementType, value: Binding<Double?>, onSave: @escaping (Double) -> Void) {
        self.type = type
        self._value = value
        self.onSave = onSave
        self._textValue = State(initialValue: value.wrappedValue.map { String(format: "%.2f", $0) } ?? "")
    }
    
    var body: some View {
        HStack {
            Label(type.rawValue, systemImage: type.icon)
                .font(.subheadline)
            
            Spacer()
            
            HStack(spacing: 4) {
                TextField("0.0", text: $textValue)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: textValue) { _, newValue in
                        if let d = Double(newValue) {
                            onSave(d)
                        }
                    }
                
                Text(type.symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
