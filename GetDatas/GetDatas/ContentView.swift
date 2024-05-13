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
                if isMeasuringHeartRate {
                      Button("정지", action: {
                          health.stopMeasuringHeartRate()
                          isMeasuringHeartRate = false
                      })
                      .padding()
                  } else {
                      Button("심박수 측정 시작", action: {
                          health.startMeasuringHeartRate()
                          isMeasuringHeartRate = true
                      })
                      .padding()
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
