import SwiftUI

struct RecipeEditLockModifier: ViewModifier {
    let hideWhenLocked: Bool
    let showLockIcon: Bool
    
    func body(content: Content) -> some View {
        if AppSettings.shared.isRecipeEditLocked {
            if hideWhenLocked {
                EmptyView()
            } else {
                content
                    .disabled(true)
                    .overlay(alignment: .topTrailing) {
                        if showLockIcon {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .padding(2)
                                .background(.background)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
            }
        } else {
            content
        }
    }
}

extension View {
    /// Applies a restriction based on the recipe edit lock setting.
    func recipeEditLocked(hide: Bool = false, showIcon: Bool = false) -> some View {
        self.modifier(RecipeEditLockModifier(hideWhenLocked: hide, showLockIcon: showIcon))
    }
}
