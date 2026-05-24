import SwiftUI

struct AppLockView: View {
    @State private var pin: String = ""
    @State private var showError = false

    private let pinLength = 4

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text(String(localized: "Welcome to Daily Jolly"))
                    .font(.title2.bold())

                Text(String(localized: "Enter the access PIN to use this app."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 24) {
                ForEach(0..<pinLength, id: \.self) { index in
                    PinDigit(digit: digit(at: index), isFocused: pin.count == index)
                }
            }
            .padding(.vertical)

            Text(String(localized: "Incorrect PIN"))
                .font(.caption)
                .foregroundStyle(.red)
                .opacity(showError ? 1 : 0)

            Spacer()

            NumericKeypad(onPress: handlePress)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .interactiveDismissDisabled()
    }

    private func digit(at index: Int) -> String? {
        guard index < pin.count else { return nil }
        let stringIndex = pin.index(pin.startIndex, offsetBy: index)
        return String(pin[stringIndex])
    }

    private func handlePress(_ value: String) {
        if value == "back" {
            if !pin.isEmpty {
                pin.removeLast()
                showError = false
            }
            return
        }

        guard pin.count < pinLength else { return }
        pin.append(value)

        if pin.count == pinLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                verify()
            }
        }
    }

    private func verify() {
        if pin == AppSettings.appUnlockPin {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            AppSettings.shared.isAppUnlocked = true
        } else {
            showError = true
            pin = ""
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    AppLockView()
}
