import SwiftUI

extension View {

    /// Applies a Liquid Glass background on iOS 26+, falls back to a tinted opacity background on older OS.
    @ViewBuilder
    func liquidGlassCard(
        tint: Color = .gray,
        opacity: Double = 0.1,
        cornerRadius: CGFloat = 12
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular.tint(tint.opacity(opacity)),
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
        } else {
            self
                .background(tint.opacity(opacity))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    /// Applies a Liquid Glass background using a neutral material on iOS 26+, falls back to `.fill.quinary`.
    @ViewBuilder
    func liquidGlassMaterial(cornerRadius: CGFloat = 12) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self
                .background(.fill.quinary)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    /// Wraps content in a Liquid Glass prominent (tinted) button style on iOS 26+, falls back to a solid background.
    @ViewBuilder
    func liquidGlassProminent(
        tint: Color = .accentColor,
        cornerRadius: CGFloat = 16
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular.tint(tint).interactive(),
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
        } else {
            self
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
