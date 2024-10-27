import SwiftUI
import UserNotifications

struct HomeView: View {
    @State private var optimalSleepTime: String = "7시간"  // 기본값
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showSleepTrackingView = false  // SleepTrackingView로 이동하기 위한 상태
    @State private var showAccountManagementView = false  // AccountManagementView로 이동하기 위한 상태
    @State private var startBedtime = true
    @State private var receiveAlarm = true
    
    @State private var sleepTime: String = ""
    @State private var fellAsleepTime: String = ""
    @State private var awakeTime: String = ""
    @State private var timeOnBed: String = ""

    
    @State private var selectedBedtime = {
        if let savedTime = UserDefaults.standard.object(forKey: "selectedBedTime") as? Date {
            return savedTime
        } else {
            return Date()
        }
    }()
    
    @State private var selectedAlarmTime = {
        if let savedTime = UserDefaults.standard.object(forKey: "selectedAlarmTime") as? Date {
            return savedTime
        } else {
            return Date()
        }
    }()
    
    @State private var selectedWakeup = {
        if let wakeUpTime = UserDefaults.standard.object(forKey: "selectedWakeUp") as? Int {
            return wakeUpTime
        } else {
            return 30
        }
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    // 알림 권한 요청 함수
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error.localizedDescription)")
            }
            if granted {
                print("알림 권한이 승인되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
        }
    }
    
    // 알림 예약 함수
    private func scheduleBedtimeNotification() {
        guard startBedtime else {
            cancelBedtimeNotification()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "수면 시간 알림"
        content.body = "지정하신 수면 시간입니다."
        content.sound = .default

        // 타임존 설정 (예: 사용자의 지역 타임존 사용)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current // 또는 특정 타임존 설정 가능

        // 매일 반복되는 알림을 위해 날짜를 제외하고 시간과 분만 사용
        let triggerDate = calendar.dateComponents([.hour, .minute], from: selectedBedtime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        let request = UNNotificationRequest(identifier: "bedtimeNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 오류: \(error.localizedDescription)")
            } else {
                print("매일 알림 예약 완료: \(triggerDate)")
            }
        }
    }
    
    // 알림 취소 함수
    private func cancelBedtimeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtimeNotification"])
    }
    
    // 상태가 변경될 때 알림 업데이트
    private func updateBedtimeNotification() {
        if startBedtime == true {
            scheduleBedtimeNotification()
        } else {
            cancelBedtimeNotification()
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                TopNav()

                // 환영 메시지
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(sessionManager.username)님, 안녕하세요!")  // username을 사용
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(.black)

                        HStack {
                            Text("\(sessionManager.username)님의 최적 수면 시간은 \(optimalSleepTime) 입니다.")
                                           .font(Font.system(size: 14))
                                           .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 23) // 좌우 여백 추가
                    .padding(.vertical, 20)
                    

                    // 최근 수면 정보 카드
                    VStack(alignment: .leading) {
                        HStack {
                            Text("최근 수면 정보")
                                .font(Font.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                NotificationCenter.default.post(name: Notification.Name("changeBottomNav"),
                                                                object: BottomNav.Tab.sleep)
                                
                            }) {
                                Text("분석 보기")
                                    .font(Font.system(size: 15))
                                    .foregroundColor(Color.deepNavy)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 25) {
                                HStack(spacing: 16) {
                                    Image("moon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(sleepTime)")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Time in sleep")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Image("watch")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(timeOnBed)")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Went to bed")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 25){
                                HStack(spacing: 16) {
                                    Image("zzz")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(fellAsleepTime)")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Fell asleep")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Image("sun")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(awakeTime)")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Wake up time")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 18)
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1)) // 연한 회색 배경
                    )
                    .padding(.horizontal, 22) // 카드 바깥의 좌우 여백
                    .padding(.bottom, 20)

                    // 취침 시간 및 알람 카드
                    HStack(spacing: 20){
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image("bed")
                                    .resizable()
                                    .frame(width: 24, height: 18)
                                Spacer()
                                Button(action: {
                                    NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                                    object: BedTimeAlarmView.Tab.bedtime)
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            Text("취침 시간")
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Text("\(dateFormatter.string(from: selectedBedtime))")
                                .font(Font.system(size: 12))
                                .foregroundColor(.gray)
                            Toggle(isOn: $startBedtime) {
                                Text("")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.mint))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1)) // 연한 회색 배경
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image("alert")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Spacer()
                                Button(action: {
                                    NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                                    object: BedTimeAlarmView.Tab.alarm)
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            Text("알람")
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Text("\(dateFormatter.string(from: selectedAlarmTime.addingTimeInterval(-Double(selectedWakeup * 60)))) ~ \(dateFormatter.string(from: selectedAlarmTime))")
                                .font(Font.system(size: 12))
                                .foregroundColor(.gray)
                            Toggle(isOn: $receiveAlarm) {
                                Text("")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.mint))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1)) // 연한 회색 배경
                        )
                    }
                    .padding(.horizontal, 22) // 카드 바깥의 좌우 여백

                    Spacer()

                    // 지금 취침하기 버튼
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                        object: BedTimeAlarmView.Tab.sleepTrack)
                    }) {
                        Text("지금 취침하기")
                            .font(Font.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.deepNavy)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                requestNotificationAuthorization()
                updateBedtimeNotification()
                fetchOptimalSleepTime()
                fetchDailySleepAnalysis()
            }
            .onChange(of: startBedtime) {
                updateBedtimeNotification()
            }
        }
    }
    
    func fetchDailySleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/analysis?range=daily")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching daily sleep analysis: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
//            // 서버에서 받은 원본 데이터를 문자열로 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let responseData = try JSONDecoder().decode(DailySleepResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseData.isSuccess {
                        // 데이터를 정상적으로 처리
                        self.sleepTime = responseData.data.sleepTime
                        self.fellAsleepTime = responseData.data.fellAsleepTime
                        self.awakeTime = responseData.data.awakeTime
                        self.timeOnBed = responseData.data.timeOnBed
                    } else {
                        // 서버 에러가 발생했을 때 사용자에게 메시지 표시
                        print("Failed to fetch daily sleep analysis: \(responseData.message)")
                    }
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchOptimalSleepTime() {
        guard let accessToken = sessionManager.accessToken else {
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/best")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching optimal sleep time: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }

            // 서버에서 받은 원본 데이터를 문자열로 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let responseData = try JSONDecoder().decode(SleepResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseData.isSuccess {
                        self.optimalSleepTime = responseData.data.bestTime
                    } else {
                        // 서버 에러 메시지를 사용자에게 알림
                        print("Failed to fetch optimal sleep time: \(responseData.message)")
                        // 에러 메시지를 뷰에서 보여줄 수 있도록 처리 (예: Alert)
                    }
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    struct DailySleepResponse: Codable {
        let isSuccess: Bool
        let code: String
        let message: String
        let data: SleepData
    }

    struct SleepData: Codable {
        let sleptAt: String
        let score: Int
        let badAwakeReason: String?
        let awakeTime: String
        let fellAsleepTime: String
        let sleepTime: String
        let timeOnBed: String
    }


}

struct SleepResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: SleepData
}

struct SleepData: Codable {
    let bestTime: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SessionManager())  // Preview에서 SessionManager 제공
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
    }
}
