import SwiftUI

enum PinMode {
    case setup
    case verify
}

struct PinEntryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let mode: PinMode
    let onComplete: (String) -> Void
    
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirming = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let pinLength = 4
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title2.bold())
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // PIN Digits
                HStack(spacing: 24) {
                    ForEach(0..<pinLength, id: \.self) { index in
                        PinDigit(digit: getDigit(at: index), isFocused: pin.count == index)
                    }
                }
                .padding(.vertical)
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                // Keypad
                NumericKeypad(onPress: handlePress)
                    .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var title: String {
        switch mode {
        case .setup:
            return isConfirming ? String(localized: "Confirm PIN") : String(localized: "Set 4-Digit PIN")
        case .verify:
            return String(localized: "Enter PIN")
        }
    }
    
    private var subtitle: String {
        switch mode {
        case .setup:
            return String(localized: "Set a PIN to lock recipe editing. You will need this PIN to unlock later.")
        case .verify:
            return String(localized: "Please enter your 4-digit PIN to unlock recipe editing.")
        }
    }
    
    private func getDigit(at index: Int) -> String? {
        if index < pin.count {
            let stringIndex = pin.index(pin.startIndex, offsetBy: index)
            return String(pin[stringIndex])
        }
        return nil
    }
    
    private func handlePress(_ value: String) {
        if value == "back" {
            if !pin.isEmpty {
                pin.removeLast()
                showError = false
            }
            return
        }
        
        if pin.count < pinLength {
            pin.append(value)
            
            if pin.count == pinLength {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    processInput()
                }
            }
        }
    }
    
    private func processInput() {
        switch mode {
        case .setup:
            if !isConfirming {
                confirmPin = pin
                pin = ""
                isConfirming = true
            } else {
                if pin == confirmPin {
                    onComplete(pin)
                    dismiss()
                } else {
                    errorMessage = String(localized: "PINs do not match. Please try again.")
                    showError = true
                    pin = ""
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
            
        case .verify:
            onComplete(pin)
            // The caller will verify the PIN and dismiss or show error
            // However, it's easier to verify here if we have access to AppSettings
            if pin == AppSettings.shared.recipePin {
                dismiss()
            } else {
                errorMessage = String(localized: "Incorrect PIN")
                showError = true
                pin = ""
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}

private struct PinDigit: View {
    let digit: String?
    let isFocused: Bool
    
    var body: some View {
        Circle()
            .stroke(isFocused ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
            .background(
                Circle()
                    .fill(digit == nil ? Color.clear : Color.primary)
                    .padding(4)
            )
            .frame(width: 20, height: 20)
    }
}

private struct NumericKeypad: View {
    let onPress: (String) -> Void
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "back"]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 40) {
                    ForEach(row, id: \.self) { button in
                        if button.isEmpty {
                            Spacer().frame(width: 80, height: 80)
                        } else {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                onPress(button)
                            } label: {
                                if button == "back" {
                                    Image(systemName: "delete.left")
                                        .font(.title)
                                } else {
                                    Text(button)
                                        .font(.title.bold())
                                }
                            }
                            .buttonStyle(KeypadButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

private struct KeypadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 80, height: 80)
            .background(configuration.isPressed ? Color.secondary.opacity(0.2) : Color.clear)
            .foregroundStyle(.primary)
            .clipShape(Circle())
    }
}

#Preview {
    PinEntryView(mode: .setup) { _ in }
}
