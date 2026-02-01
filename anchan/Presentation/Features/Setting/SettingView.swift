import SwiftUI

struct SettingView: View {
    @State private var viewModel = SettingViewModel()

    var body: some View {
       
            Form {
                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            }
            .navigationTitle("Setting")
        
    }
}
