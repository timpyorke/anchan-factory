import SwiftUI

struct ListRow<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
                .contentShape(Rectangle())
                .padding(.vertical, 4)
        }
        .buttonStyle(.row)
    }
}
