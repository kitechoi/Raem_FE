import SwiftUI

struct SleepDetailView: View {
    @State private var rating: Int = 0
    @State private var showSleepRatingView = false
    @State private var showBedTimeAlarmView = false
    @State private var now = Date()
    @State private var showAlert = false
    @State private var isAlarmOn = false
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var stageAiManager: StageAiPredictionManager
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var red: Double = 255
    @State private var green: Double = 200
    @State private var blue: Double = 124
    @State private var gradualTime: Int = 20
    
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
    
    init() {
        let savedRed = UserDefaults.standard.double(forKey: "red")
        let savedGreen = UserDefaults.standard.double(forKey: "green")
        let savedBlue = UserDefaults.standard.double(forKey: "blue")
        let brightness = UserDefaults.standard.double(forKey: "brightness")
        let turnOnDuration = UserDefaults.standard.integer(forKey: "TurnOnDuration")
        
        if brightness != 0 && savedRed != 0 {
            _red = State(initialValue: savedRed * brightness)
        }
        
        if brightness != 0 && savedGreen != 0 {
            _green = State(initialValue: savedGreen * brightness)
        }
        
        if brightness != 0 && savedBlue != 0 {
            _blue = State(initialValue: savedBlue * brightness)
        }
        
        if turnOnDuration != 0 {
            _gradualTime = State(initialValue: turnOnDuration)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // 상단 Back 버튼
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
                }
                .padding(.leading, 16)
                .padding(.top, 70)
                
                Spacer()
                
                Text("\(formattedTime)").onReceive(timer) { time in
                    self.now = time
                    checkAlarmTime(bleManager: bleManager)
                }
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
                
                Text("\(formattedDate)").onReceive(timer) { time in
                    self.now = time
                }
                .font(.system(size: 18))
                .foregroundColor(.gray)
                
                Spacer()
                
                // 소리 및 음악, 알람 설정 섹션
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                        Text("수면 BGM 재생")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        Spacer()
                        Button(action: {
                            NotificationCenter.default.post(name: Notification.Name("changeBottomNav"),
                                                            object: BottomNav.Tab.sounds)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5))
                    )
                    
                    HStack {
                        Image(systemName: "alarm")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                        Text("알람")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        Spacer()
                        Text("\(dateFormatter.string(from: selectedAlarmTime.addingTimeInterval(-Double(selectedWakeup * 60)))) ~ \(dateFormatter.string(from: selectedAlarmTime))")
                            .font(Font.system(size: 16))
                            .foregroundColor(.gray)
                        Button(action: {
                            NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                            object: BedTimeAlarmView.Tab.alarm)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5))
                    )
                    .onTapGesture {
                        showBedTimeAlarmView = true
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // 기상 버튼
                Button(action: {
                    showSleepRatingView = true
                    bleManager.turnOffAlarm("Off")
                }) {
                    Text("기상")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.deepNavy)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            
            if showSleepRatingView {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.1)
                        .onTapGesture {
                            showSleepRatingView = false
                        }

                    ScoreBottomSheet(isPresented: $showSleepRatingView, height: 350) {
                        VStack {
                            Spacer()
                            
                            Text("오늘의 수면은 어땠나요?")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("이번 수면 시간은 총 6시간 30분 입니다.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.vertical, 20)
                            
                            HStack(spacing: 10) {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(index <= rating ? .yellow : .gray)
                                }
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        updateRating(from: value)
                                    }
                            )
                            
                            Button(action: {
                                showSleepRatingView = false
                                showAlert = true
                                // 데이터 전송 (UserDefaults에 저장)
                                UserDefaults.standard.set(rating, forKey: "sleepRating")
                            }) {
                                Text("기록하기")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.deepNavy)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 35)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("기록되었습니다!"), message: Text("홈 화면으로 이동합니다."), dismissButton: .default(Text("확인"), action: {
                // 홈 화면으로 이동
                NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                object: BedTimeAlarmView.Tab.none)
            }))
        }
    }
    
    private func checkAlarmTime(bleManager: BLEManager) {
        // 현재 시간이 알람 시간과 같은지 확인 (분 단위로)
        let nowComponents = Calendar.current.dateComponents([.hour, .minute], from: now)
        let alarmComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedAlarmTime)

        // 현재 시간이 알람 시간과 일치하는지 확인
        if nowComponents == alarmComponents && !isAlarmOn && !stageAiManager.doesAiAlarmTurnedOn{
            print("NonAI Alarm on")
            isAlarmOn = true
            
            print("\(gradualTime),\(red),\(green),\(blue),alarm,60")
            bleManager.turnOnAlarm("\(gradualTime),\(red),\(green),\(blue),alarm,40")
        }
    }
    
    private func updateRating(from drag: DragGesture.Value) {
        let location = drag.location.x
        let starWidth = CGFloat(40)
        let newRating = Int(location / starWidth) + 1
        if newRating != rating && newRating > 0 && newRating <= 5 {
            rating = newRating
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        return formatter.string(from: now)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: now)
    }
}

// ScoreBottomSheet 구조체 추가
struct ScoreBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let height: CGFloat
    let content: () -> Content

    var body: some View {
        VStack {
            Spacer()
            VStack {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundColor(Color.gray.opacity(0.4))
                    .frame(width: 30, height: 5)
                    .padding(.top, 15)
                
                // 전달된 컨텐츠 표시
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
            }
            .frame(height: self.height)
            .background(
                Color.white
                    .clipShape(CornerShape(corners: [.topLeft, .topRight], radius: 30))
            )
        }
        .background(Color.clear)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.8), value: isPresented)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height >= height / 3 {
                        self.isPresented = false
                    }
                }
        )
    }
}

// Custom shape for the rounded corners
struct CornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//struct SleepDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SleepDetailView()
//    }
//}

