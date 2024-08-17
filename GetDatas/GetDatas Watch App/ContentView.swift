import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HealthDataViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                viewModel.startMonitoring()
            }) {
                Text("측정 시작")
                    .padding()
                    .cornerRadius(10)
            }
            
            Button(action: {
                viewModel.stopMonitoring()
            }) {
                Text("측정 중지")
                    .padding()
                    .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: ContentView {
        ContentView()
    }
}
