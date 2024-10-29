import SwiftUI

struct SettingView: View {
    @EnvironmentObject var bleManager: BLEManager
    @State private var brightness: Double = 10
    @State private var colorTemperature: Double = 0.5
    @State private var gradualTime: Int? = 10
    @State private var offTimer: Int? = 5
    @State private var selectedTab: BottomNav.Tab = .settings
    @State private var lightColor: Color = .lightAmber
    @State private var isConnected: Bool = false
    @State private var isColorViewOn: Bool = false

    init() {
        let red = UserDefaults.standard.double(forKey: "red")
        let green = UserDefaults.standard.double(forKey: "green")
        let blue = UserDefaults.standard.double(forKey: "blue")
        let turnOnDuration = UserDefaults.standard.integer(forKey: "TurnOnDuration")
        let turnOffAfter = UserDefaults.standard.integer(forKey: "TurnOffAfter")
        let brightness = UserDefaults.standard.double(forKey: "brightness")
        
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
            HStack {
                Text("설정")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 20)
                    .foregroundColor(.black)
            }

            ScrollView {
                VStack(alignment: .leading) {
                    Text("조명 밝기 조절")
                        .bold()
                        .foregroundColor(.black)
                    HStack {
                        Image("darkness")
                            .resizable()
                            .frame(width: 18, height: 20)
                        Slider(value: $brightness, in: 0...100, step: 10)
                            .onChange(of: brightness) {
                                if brightness < 10 {
                                    brightness = 10
                                }
                                saveBrightness(brightness: brightness)
                            }
                            .accentColor(.deepNavy)
                            .padding(.vertical, 10)
                        Image("brightness")
                            .resizable()
                            .frame(width: 14, height: 20)
                    }
                }
                
                HStack {
                    Text("조명 색상 조절")
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                    ColorPicker("", selection: $lightColor, supportsOpacity: false)
                        .onChange(of: lightColor) {
                            saveColor(color: lightColor)
                        }
                        .labelsHidden()
                }
                .padding(.vertical, 5)
                
                HStack {
                    if isColorViewOn {
                        Button(action: {bleManager.controllLED("0,0,0")
                            isColorViewOn = false
                        }){
                            Text("끄기")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10) // 상하 패딩을 추가로 설정
                                .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                                .foregroundColor(.deepNavy)
                                .cornerRadius(8)
                        }
                    }
                    
                    Button(action: {
                        let uiColor = UIColor(lightColor)
                        let red = uiColor.cgColor.components?[0] ?? 0
                        let green = uiColor.cgColor.components?[1] ?? 0
                        let blue = uiColor.cgColor.components?[2] ?? 0
                        let brightness = self.brightness
                        
                        bleManager.controllLED("\(red * brightness),\(green * brightness),\(blue * brightness)")
                        isColorViewOn = true
                    }){
                        Text("보기")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10) // 상하 패딩을 추가로 설정
                            .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                            .foregroundColor(.deepNavy)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    Text("서서히 밝아지는 시간")
                        .bold()
                        .padding(.bottom, 10)
                        .foregroundColor(.black)
                    HStack {
                        TimeOptionButton(title: "10초", selectedTime: $gradualTime, timeValue: 10)
                        TimeOptionButton(title: "40초", selectedTime: $gradualTime, timeValue: 40)
                        TimeOptionButton(title: "1분", selectedTime: $gradualTime, timeValue: 60)
                    }
                    .padding(.bottom, 30)
                }
                
                VStack(alignment: .leading) {
                    Text("꺼짐 예약")
                        .bold()
                        .padding(.bottom, 0)
                        .foregroundColor(.black)
                    HStack {
                        TurnOffTimeOptionButton(title: "5분 뒤", selectedTime: $offTimer, timeValue: 5)
                        TurnOffTimeOptionButton(title: "10분 뒤", selectedTime: $offTimer, timeValue: 10)
                        TurnOffTimeOptionButton(title: "설정 시간", selectedTime: $offTimer, timeValue: 20)
                    }
                    .padding(.bottom, 30)
                }
                
                VStack(alignment: .leading) {
                    Text("기기 연결 관리")
                        .bold()
                        .foregroundColor(.black)
                    if isConnected {
                        Text("Ræm과 연결되어 있어요.")
                            .padding(.bottom, 10)
                            .foregroundColor(.black)
                    } else {
                        Text("Ræm과 연결되어 있지 않아요.")
                            .padding(.bottom, 10)
                            .foregroundColor(.black)
                    }
                    HStack {
                        Button(action: {
                            bleManager.disconnect()
                            isConnected = false
                        }) {
                            Text("해제")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isConnected ? Color.deepNavy : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isConnected)
                        
                        Button(action: {
                            bleManager.connectDevice()
                            isConnected = true
                        }) {
                            Text("연결")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isConnected ? Color.gray : Color.deepNavy)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isConnected)
                    }
                }
            }
        }
        .padding(.top, 70)
        .padding(.horizontal, 16)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // BLEManager 상태 업데이트
            isConnected = bleManager.connectSuccess
        }
    }
    
    func saveColor(color: Color) {
        if let uiColor = UIColor(color).cgColor.components {
            let red = uiColor[0]
            let green = uiColor[1]
            let blue = uiColor[2]

            UserDefaults.standard.set(red, forKey: "red")
            UserDefaults.standard.set(green, forKey: "green")
            UserDefaults.standard.set(blue, forKey: "blue")
        }
    }
    
    func saveBrightness(brightness: Double) {
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
