import SwiftUI
import UserNotifications

struct HomeView: View {
    @State private var showSleepTrackingView = false  // SleepTrackingView로 이동하기 위한 상태
    @State private var showAccountManagementView = false  // AccountManagementView로 이동하기 위한 상태
    @EnvironmentObject var sessionManager: SessionManager
    @State private var startBedtime = true
    @State private var receiveAlarm = true
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
                            Text("\(sessionManager.username)님의 최적 수면 시간은 7시간 입니다.")
                                .font(Font.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
//                            Button(action: {
//                                // 더보기 액션 추가
//                            }) {
//                                Text("더보기")
//                                    .font(Font.system(size: 14))
//                                    .foregroundColor(Color.home_mint)
//                            }
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
                        .padding(.horizontal, 20) // 카드 내부의 좌우 여백
                        .padding(.top, 18)

                        HStack(spacing: 45) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 16) {
                                    Image("moon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4){
                                        Text("6시간 52분")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Time in sleep")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            VStack(spacing: 4) {
                                HStack(spacing: 16) {
                                    Image("zzz")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4){
                                        Text("25분")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Fell asleep")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20) // 카드 내부의 좌우 여백
                        .padding(.top, 20)
                        
                        HStack(spacing: 45) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 16) {
                                    Image("watch")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing:4) {
                                        Text("7시간 23분")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Went to bed")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 16) {
                                    Image("sun")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("07시 12분")
                                            .font(Font.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Wake up time")
                                            .font(Font.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20) // 카드 내부의 좌우 여백
                        .padding(.top, 25)
                        .padding(.bottom, 18)
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
                    .padding(.top, 20)
                    
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                requestNotificationAuthorization()
                updateBedtimeNotification()
            }
            .onChange(of: startBedtime) {
                updateBedtimeNotification()
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SessionManager())  // Preview에서 SessionManager 제공
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
    }
}
