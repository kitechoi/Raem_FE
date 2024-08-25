import SwiftUI

struct SettingView: View {
    @State private var brightness: Double = 0.5
    @State private var colorTemperature: Double = 0.5
    @State private var gradualTime: Int? = nil
    @State private var offTimer: Int? = nil
    @State private var selectedTab: BottomNav.Tab = .settings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("설정")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("조명 밝기 조절")
                    Slider(value: $brightness)
                        .padding(.vertical, 10)
                }
                
                VStack(alignment: .leading) {
                    Text("조명 색상 변경")
                    Slider(value: $colorTemperature)
                        .padding(.vertical, 10)
                }
                
                VStack(alignment: .leading) {
                    Text("서서히 밝아지는 시간")
                    HStack {
                        TimeOptionButton(title: "10분", selectedTime: $gradualTime, timeValue: 10)
                        TimeOptionButton(title: "15분", selectedTime: $gradualTime, timeValue: 15)
                        TimeOptionButton(title: "30분", selectedTime: $gradualTime, timeValue: 30)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("꺼짐 예약")
                    HStack {
                        TimeOptionButton(title: "5분 뒤", selectedTime: $offTimer, timeValue: 5)
                        TimeOptionButton(title: "10분 뒤", selectedTime: $offTimer, timeValue: 10)
                        TimeOptionButton(title: "설정 시간", selectedTime: $offTimer, timeValue: nil) // This can be configured to show a custom time picker
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        // 해제 버튼 동작
                    }) {
                        Text("해제")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // 연결 버튼 동작
                    }) {
                        Text("연결")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(true) // 비활성화된 버튼
                }
            }
            
        }
        .padding()
    }
}

struct TimeOptionButton: View {
    let title: String
    @Binding var selectedTime: Int?
    let timeValue: Int?
    
    var body: some View {
        Button(action: {
            selectedTime = timeValue
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedTime == timeValue ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.black)
                .cornerRadius(10)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
