import SwiftUI

struct SettingView: View {
    //@EnvironmentObject var bleManager: BLEManager
    @State private var brightness: Double = 10
    @State private var colorTemperature: Double = 0.5
    @State private var gradualTime: Int? = 10
    @State private var offTimer: Int? = 5
    @State private var selectedTab: BottomNav.Tab = .settings
    @State private var lightColor : Color = .lightAmber
    @State private var isConnected: Bool = false
    
    init() {
        let red = UserDefaults.standard.double(forKey: "red")
        let green = UserDefaults.standard.double(forKey: "green")
        let blue = UserDefaults.standard.double(forKey: "blue")
        let turnOnDuration = UserDefaults.standard.integer(forKey: "TurnOnDuration")
        let turnOffAfter = UserDefaults.standard.integer(forKey: "TurnOffAfter")
        let brightness = UserDefaults.standard.double(forKey: "Brightness")
        
        if red != 0 || green != 0 || blue != 0 { // 저장된 값이 있을 때
            _lightColor = State(initialValue: Color(.sRGB, red: red, green: green, blue: blue, opacity: 1.0))
        }
        
        if turnOnDuration != 0 {
            _gradualTime = State(initialValue: turnOnDuration)
        }
        
        if turnOffAfter != 0 {
            _offTimer = State(initialValue: turnOffAfter)
        }
        
        if brightness != 0 {
            _brightness = State(initialValue: brightness)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("설정")
                .font(.title)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("조명 밝기 조절")
                        .bold()
                    HStack{
                        Image("darkness")
                            .resizable()
                            .frame(width: 18, height: 20)
                        Slider(value: $brightness, in: 0...100, step: 10)
                            .onChange(of: brightness) { newValue in
                                if newValue < 10 {
                                    brightness = 10
                                }
                                saveBrightness(brightness: newValue)
                            }
                            .accentColor(.deepNavy)
                            .padding(.vertical, 10)
                        Image("brightness")
                            .resizable()
                            .frame(width: 14, height: 20)
                    }
                }
                
                HStack{
                    Text("조명 밝기 조절")
                        .bold()
                    Spacer()
                    ColorPicker("", selection: $lightColor, supportsOpacity: false)
                        .onChange(of: lightColor) { newColor in
                            saveColor(color: newColor)
                        }
                        .labelsHidden()
                }
                .padding(.vertical, 20)
                
                
                VStack(alignment: .leading) {
                    Text("서서히 밝아지는 시간")
                        .bold()
                        .padding(.bottom, 10)
                    HStack {
                        TimeOptionButton(title: "10분", selectedTime: $gradualTime, timeValue: 10)
                        TimeOptionButton(title: "15분", selectedTime: $gradualTime, timeValue: 15)
                        TimeOptionButton(title: "30분", selectedTime: $gradualTime, timeValue: 30)
                    }
                    .padding(.bottom, 30)
                }
                
                VStack(alignment: .leading) {
                    Text("꺼짐 예약")
                        .bold()
                        .padding(.bottom, 0)
                    HStack {
                        TurnOffTimeOptionButton(title: "5분 뒤", selectedTime: $offTimer, timeValue: 5)
                        TurnOffTimeOptionButton(title: "10분 뒤", selectedTime: $offTimer, timeValue: 10)
                        TurnOffTimeOptionButton(title: "설정 시간", selectedTime: $offTimer, timeValue: 20)
                    }
                    .padding(.bottom, 30)
                }
                
                VStack(alignment:.leading) {
                    Text("기기 연결 관리")
                        .bold()
                    if isConnected == true {
                        Text("Ræm과 연결되어 있어요.")
                            .padding(.bottom, 10)
                    } else {
                        Text("Ræm과 연결되어 있지 않아요.")
                            .padding(.bottom, 10)
                    }
                    HStack {
                        Button(action: {
                            //bleManager.disconnect()
                            isConnected = false
                        }) {
                            Text("해제")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isConnected == true ? Color.deepNavy : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isConnected)
                        
                        Button(action: {
                            //bleManager.connectDevice()
                            isConnected = true
                        }) {
                            Text("연결")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isConnected == true ? Color.gray : Color.deepNavy)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isConnected) // 비활성화된 버튼
                    }
                }
            }
            
        }
        .padding()
//        .onAppear {
//            if let connectSuccess = bleManager.connectSuccess {
//                isConnected = connectSuccess
//            }
//        }
    }
    
    func saveColor(color: Color){
        if let uiColor = UIColor(color).cgColor.components {
            let red = uiColor[0]
            let green = uiColor[1]
            let blue = uiColor[2]

            UserDefaults.standard.set(red, forKey: "red")
            UserDefaults.standard.set(green, forKey: "green")
            UserDefaults.standard.set(blue, forKey: "blue")
        }
    }
    
    func saveBrightness(brightness: Double){
        UserDefaults.standard.set(brightness, forKey: "brightness")
    }
}

struct TimeOptionButton: View {
    let title: String
    @Binding var selectedTime: Int?
    let timeValue: Int?
    
    var body: some View {
        Button(action: {
            selectedTime = timeValue
            UserDefaults.standard.setValue(timeValue, forKey: "TurnOnDuration")
        }) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTime == timeValue ? Color.white : Color.gray)
                .padding()
                .background(selectedTime == timeValue ? Color.deepNavy : Color.gray.opacity(0.3))
                .foregroundColor(.black)
                .cornerRadius(10)
        }
    }
}

struct TurnOffTimeOptionButton: View {
    let title: String
    @Binding var selectedTime: Int?
    let timeValue: Int?
    
    var body: some View {
        Button(action: {
            selectedTime = timeValue
            UserDefaults.standard.setValue(timeValue, forKey: "TurnOffAfter")
        }) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTime == timeValue ? Color.white : Color.gray)
                .padding()
                .background(selectedTime == timeValue ? Color.deepNavy : Color.gray.opacity(0.3))
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
