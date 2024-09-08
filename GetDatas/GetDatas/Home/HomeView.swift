import SwiftUI

struct HomeView: View {
    @State private var optimalSleepTime: String = "7시간"  // 기본값
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showSleepTrackingView = false  // SleepTrackingView로 이동하기 위한 상태
    @State private var showAccountManagementView = false  // AccountManagementView로 이동하기 위한 상태
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
                fetchOptimalSleepTime()  // 뷰가 나타날 때 API 호출
            }
        }
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
