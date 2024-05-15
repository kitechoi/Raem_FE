import SwiftUI

struct ContentView: View {
    let health = HealthKitService()
    
    var body: some View {
        VStack {
            Button("수면 데이터 출력") {
                health.fetchSleepData()
            }
            Button("심박수 측정 시작") {
                health.startMeasuringHeartRate()
            }
            Button("심박수 측정 정지") {
                health.stopMeasuringHeartRate()
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
