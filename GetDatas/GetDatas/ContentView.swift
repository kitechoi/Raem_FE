import SwiftUI

struct ContentView: View {
    let health = HealthKitService()
    @State private var isMeasuringHeartRate = false

    var body: some View {
        NavigationView {
            VStack{
                Button("수면 데이터 불러오기") {
                    health.getSleepData()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
