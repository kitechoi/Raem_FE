import SwiftUI

struct BedTimeAlarmView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var stageAiPredictionManager: StageAiPredictionManager

    enum Tab {
        case bedtime
        case alarm
        case none
        case sleepTrack
        case sleepDetail
    }

    var body: some View {
        VStack(spacing: 20) {
            // 상단 Back 버튼 및 탭 선택
            HStack {
                Button(action: {
                    NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                    object: BedTimeAlarmView.Tab.none)
                }) {
                    Image("backbutton")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("취침 시간")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(selectedTab == .bedtime ? .black : .gray)
                    .onTapGesture {
                        selectedTab = .bedtime
                    }
                Spacer()
                Text("알람")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(selectedTab == .alarm ? .black : .gray)
                    .onTapGesture {
                        selectedTab = .alarm
                    }
                Spacer()
                // 빈 공간 확보
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.top, 70) // 상단에 약간의 여백 추가

            // 선택된 탭에 따라 다른 뷰 표시
            ScrollView {
                if selectedTab == .bedtime {
                    BedtimeView()
                } else {
                    AlarmView(stageAiPredictionManager: stageAiPredictionManager)
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

struct BedtimeView: View {
    @State private var selectedTime = {
        if let savedTime = UserDefaults.standard.object(forKey: "selectedBedTime") as? Date {
            return savedTime
        } else {
            return Date()
        }
    }()
    @State private var receiveAlarm = true
    @State private var optimalSleepTime: String = "7시간 30분"
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Please select time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal, 16)
            .environment(\.colorScheme, .light)
            .onChange(of: selectedTime) {
                UserDefaults.standard.set(selectedTime, forKey: "selectedBedTime")
            }

            Text("수면 시간 목표는 \(optimalSleepTime) 입니다.\n취침시간 및 알람시간에 근거함")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Toggle(isOn: $receiveAlarm) {
                Text("취침 시간 알림 받기")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5))
            )
            .padding(.horizontal, 16)
            .toggleStyle(SwitchToggleStyle(tint: Color.mint))
        }
        .padding(.top, 20) // 상단 여백 추가
        .onAppear {
            fetchOptimalSleepTime()
        }
    }

    func fetchOptimalSleepTime() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/best")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "데이터를 받지 못했습니다."
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let responseData = try JSONDecoder().decode(SleepResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseData.isSuccess {
                        self.optimalSleepTime = responseData.data.bestTime
                    } else {
                        self.errorMessage = responseData.message  // 서버에서 받은 에러 메시지 표시
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "응답을 디코딩하는 중 오류가 발생했습니다: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct AlarmView: View {
    @ObservedObject var stageAiPredictionManager: StageAiPredictionManager  // StageAiPredictionManager 객체
    
    @State private var selectedTime: Date = {
        if let savedTime = UserDefaults.standard.object(forKey: "selectedAlarmTime") as? Date {
            return savedTime
        } else {
            return Date()
        }
    }()
    
    @State private var selectedWakeup: Int = {
        if let wakeUpTime = UserDefaults.standard.object(forKey: "selectedWakeUp") as? Int {
            return wakeUpTime
        } else {
            return 30
        }
    }()
    
    @State private var optimalSleepTime: String = "7시간 30분"
    @State private var errorMessage: String = ""
    @State private var showingWakeupSheet = false
    @State private var showingRealarmSheet = false
    @State private var selectedRealarm: String = {
        if let realarmAfter = UserDefaults.standard.string(forKey: "selectedRealarm") {
            return realarmAfter
        } else {
            return "사용 안 함"
        }
    }()
    
    @State private var receiveAlarm: Bool = UserDefaults.standard.bool(forKey: "receiveAlarm")

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Please enter a date", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal, 16)
            .environment(\.colorScheme, .light)
            .onChange(of: selectedTime) {
                UserDefaults.standard.set(selectedTime, forKey: "selectedAlarmTime")
            }
            

            Text("수면 시간 목표는 \(optimalSleepTime) 입니다.\n취침시간 및 알람시간에 근거함")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // "설정하기" 버튼 추가
            Button(action: {
                selectedTime = updateToToday(time: selectedTime)
                // 설정 버튼 클릭 시, 알람 시간과 여분 시간을 저장
                UserDefaults.standard.set(selectedTime, forKey: "selectedAlarmTime")
                UserDefaults.standard.set(selectedWakeup, forKey: "selectedWakeUp")
                
                // StageAiPredictionManager에 알람 시간과 여분 시간 전달
                stageAiPredictionManager.setAlarmTime(alarmTime: selectedTime, wakeUpBufferMinutes: selectedWakeup)
            }) {
                HStack {
                    Spacer()
                    Text("설정하기")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.mint)
                )
            }
            .padding(.horizontal, 16)

            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("스마트 알람")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $receiveAlarm)
                        .toggleStyle(SwitchToggleStyle(tint: Color.mint))
                        .onChange(of: receiveAlarm) {
                            UserDefaults.standard.set(receiveAlarm, forKey: "receiveAlarm")
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)

                HStack {
                    Text("기상 시간대")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(selectedWakeup)분")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Button(action: {
                        showingWakeupSheet = true
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .confirmationDialog("기상 시간대", isPresented: $showingWakeupSheet) {
                        Button("30분") {
                            selectedWakeup = 30
                            UserDefaults.standard.set(30, forKey: "selectedWakeUp")
                        }
                        Button("45분") {
                            selectedWakeup = 45
                            UserDefaults.standard.set(45, forKey: "selectedWakeUp")
                        }
                        Button("60분") {
                            selectedWakeup = 60
                            UserDefaults.standard.set(60, forKey: "selectedWakeUp")
                        }
                        Button("취소", role: .cancel) {}
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)

                HStack {
                    Text("다시 알림")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Text(selectedRealarm)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Button(action: {
                        showingRealarmSheet = true
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .confirmationDialog("다시 알림", isPresented: $showingRealarmSheet) {
                        Button("사용 안 함") {
                            selectedRealarm = "사용 안 함"
                            UserDefaults.standard.set("사용 안 함", forKey: "selectedRealarm")
                        }
                        Button("5분 뒤") {
                            selectedRealarm = "5분 뒤"
                            UserDefaults.standard.set("5분 뒤", forKey: "selectedRealarm")
                        }
                        Button("10분 뒤") {
                            selectedRealarm = "10분 뒤"
                            UserDefaults.standard.set("10분 뒤", forKey: "selectedRealarm")
                        }
                        Button("15분 뒤") {
                            selectedRealarm = "15분 뒤"
                            UserDefaults.standard.set("15분 뒤", forKey: "selectedRealarm")
                        }
                        Button("30분 뒤") {
                            selectedRealarm = "30분 뒤"
                            UserDefaults.standard.set("30분 뒤", forKey: "selectedRealarm")
                        }
                        Button("취소", role: .cancel) {}
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }

        }
        .padding(.top, 20) // 상단 여백 추가
        .onAppear {
            fetchOptimalSleepTime()
        }
    }

    
    func fetchOptimalSleepTime() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/best")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "데이터를 받지 못했습니다."
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let responseData = try JSONDecoder().decode(SleepResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseData.isSuccess {
                        self.optimalSleepTime = responseData.data.bestTime
                    } else {
                        self.errorMessage = responseData.message  // 서버에서 받은 에러 메시지 표시
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "응답을 디코딩하는 중 오류가 발생했습니다: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

private func updateToToday(time: Date) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.hour, .minute], from: time)
    let today = Date()
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
    
    components.year = todayComponents.year
    components.month = todayComponents.month
    components.day = todayComponents.day
    
    return calendar.date(from: components) ?? time
}

//struct BedTimeAlarmView_Previews: PreviewProvider {
//    static var previews: some View {
//        BedTimeAlarmView(selectedTab: .constant(.bedtime))
//    }
//}
