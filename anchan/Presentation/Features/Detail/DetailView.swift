import SwiftUI
struct DetailView : View {
    let productName: String
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(spacing: 20) {
            Text("รายละเอียดสินค้า")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(productName) // แสดงค่าที่รับมา
                .font(.largeTitle)
                .bold()
            
            Button("กลับหน้าหลัก") {
                router.goBack()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}



