
import SwiftUI

struct InventoryView: View {
    @State private var viewModel = InventoryViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("InventoryView")
                .font(.largeTitle.bold())
        }
        .navigationTitle("Home")
        
    }
}
