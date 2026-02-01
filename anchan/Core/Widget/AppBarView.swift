import SwiftUI

struct AppBarView<Trailing: View, Leading: View>: View {

    let title: String
    let leading: Leading
    let trailing: Trailing

    init(
        title: String,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
            leading
            Spacer()
            Text(title)
                .font(.headline)
            Spacer()
            trailing
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
