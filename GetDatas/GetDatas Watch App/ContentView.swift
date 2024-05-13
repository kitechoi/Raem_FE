import SwiftUI

struct ContentView: View {
    let workoutSessionManager = WorkoutSessionManager()

    var body: some View {
        VStack {
            Button("수면 데이터 불러오기") {
                workoutSessionManager.startWorkout()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
