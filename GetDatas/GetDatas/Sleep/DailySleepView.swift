import SwiftUI
import Charts
import HealthKit

struct DailyView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var popUpVisible: Bool = false
    @State private var selectedReason: Reason? = nil
    @State private var rating: Int = UserDefaults.standard.integer(forKey: "sleepRating")
    @State private var isLoading = false
    @State private var showAlert = false
    
    // 당일 날짜 및 시간으로 초기화
    @State private var sleptAt: String = formatDate(Date()) // 오늘 날짜
    @State private var sleepHour: String = formatHour(Date()) // 현재 시
    @State private var sleepMinute: String = formatMinute(Date()) // 현재 분
    
    @State private var sleepData: [HKSleepAnalysis] = []
    @State private var loadingData: Bool = false
    
    @State private var sleepDataId: String = ""
    @State private var sleepTime: String = ""
    @State private var fellAsleepTime: String = ""
    @State private var awakeTime: String = ""
    @State private var timeOnBed: String = ""
    @State private var badSleepReason: String = ""

    private let healthStore = HKHealthStore()

    enum Reason: String {
        case caffeine = "COFFEE"
        case exercise = "EXERCISE"
        case stress = "STRESS"
        case alcohol = "ALCOHOL"
        case smartphone = "SMARTPHONE"
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 20) {
                    HStack {
                        Text("수면 별점")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(index <= rating ? .yellow : .gray)
                        }
                    }
                    
                    Text("오늘의 별점은 \(rating)점 입니다.")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                    
                    if rating <= 3 {
                        if badSleepReason == "" {
                            Button(action: {
                                popUpVisible = true
                            }) {
                                Text("더보기")
                                    .font(.system(size: 17))
                                    .foregroundColor(.deepNavy)
                            }
                        } else {
                            Text("수면 방해 요인: \(badSleepReason)")
                                .font(.system(size: 15))
                                .foregroundColor(.deepNavy)
                                .padding(.top, -18)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("수면 깊이")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
                            HStack(spacing: 12) {
                                Image("moon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                
                                var sleptAtSplit = sleptAt.split(separator: "-")
                                Text("\(sleptAtSplit[1])")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black) +
                                Text("월")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black) +
                                Text(" \(sleptAtSplit[2])")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black) +
                                Text("일")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            Text("\(sleptAt)")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            if loadingData {
                                ProgressView("Loading data...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(height: 200)
                            } else if sleepData.isEmpty {
                                Text("No sleep data available.")
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            } else {
                                Chart {
                                    ForEach(sleepData.filter { data in
                                        data.level != 0 && data.level != 1 // 단계 0과 1은 제외
                                    }) { data in
                                        RectangleMark(
                                            xStart: .value("시작 시간", data.startDate),
                                            xEnd: .value("종료 시간", data.endDate),
                                            y: .value("수면 단계", levelText(for: data.level))
                                        )
                                        .foregroundStyle(self.color(for: data.level)) // 수면 단계별 색상 적용
                                        .cornerRadius(3) // 각 블록에 둥근 모서리 적용
                                    }
                                }
                                .frame(height: 200)
                            }
                        }
                        .onAppear(perform: loadSleepData)
                        
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 20) {
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
                            
                            VStack(alignment: .leading, spacing: 20){
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
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            if popUpVisible {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                popUpVisible = false
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                            }
                        }
                        
                        Text("오늘 해당하는 사항이 있나요?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        VStack {
                            VStack(alignment: .leading) {
                                tabReason(for: .caffeine, label: "카페인 음료")
                                tabReason(for: .exercise, label: "격렬한 운동")
                                tabReason(for: .stress, label: "과도한 스트레스")
                                tabReason(for: .alcohol, label: "음주")
                                tabReason(for: .smartphone, label: "자기 전 스마트폰 사용")
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if let reason = selectedReason {
                                    submitReason(reason: reason.rawValue)
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(height: 50)
                                } else {
                                    Text("기록하기")
                                        .font(.system(size: 18, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.deepNavy)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(width: 297, height: 297)
                    .background(Color.lightGray)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: popUpVisible)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("기록되었습니다."), message: nil, dismissButton: .default(Text("확인")))
        }
        .onAppear {
            fetchDailySleepAnalysis()
        }
    }
    
    private func tabReason(for reason: Reason, label: String) -> some View {
        Button(action: {
            selectedReason = (selectedReason == reason) ? nil : reason
        }) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(selectedReason == reason ? Color.deepNavy : Color.gray)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Color.gray)
        }
    }

    private func submitReason(reason: String) {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token")
            return
        }
        
        let url = URL(string: "https://www.raem.shop/api/sleep/data")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "sleepDataId": sleepDataId,
            "reason": reason
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error submitting reason: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Non-200 HTTP response: \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let responseData = try JSONDecoder().decode(SubmitReasonResponse.self, from: data)
                    print(responseData)
                    if responseData.isSuccess {
                        print("Reason successfully submitted: \(responseData.data.updatedAt)")
                        // submitReason 완료 후 fetchDailySleepAnalysis 호출
                        self.fetchDailySleepAnalysis()  // 데이터를 새로 불러옴
                        popUpVisible = false // 팝업을 닫음
                    } else {
                        print("Failed to submit reason: \(responseData.message)")
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    struct SubmitReasonResponse: Codable {
        let isSuccess: Bool
        let code: String
        let message: String
        let data: ReasonResponseData
    }

    struct ReasonResponseData: Codable {
        let updatedAt: String
    }
    
    private func loadSleepData() {
        guard #available(iOS 16.0, *) else {
            return
        }
        
        let startDateComponents = DateComponents(year: 2024, month: 9, day: 12, hour: 0, minute: 0)
        let startDate = Calendar.current.date(from: startDateComponents)!
        
        let endDateComponents = DateComponents(year: 2024, month: 9, day: 12, hour: 12, minute: 0)
        let endDate = Calendar.current.date(from: endDateComponents)!
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKCategorySample], error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                sleepData = results.map { HKSleepAnalysis(sample: $0) }
                loadingData = false
            }
        }
        
        healthStore.execute(query)
        loadingData = true
    }
    
    private func color(for level: Int) -> Color {
        switch level {
        case 2: return .red // Awake
        case 3: return .blue // Core
        case 4: return .green // Deep
        case 5: return .purple // REM
        default: return .gray
        }
    }
    
    private func levelText(for level: Int) -> String {
        switch level {
        case 2: return "Awake"
        case 3: return "Core"
        case 4: return "Deep"
        case 5: return "REM"
        default: return "Unknown"
        }
    }
    
    func fetchDailySleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token found")
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

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Non-200 HTTP response received")
                    return
                }
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let responseData = try JSONDecoder().decode(DailySleepResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseData.isSuccess {
                        self.sleepDataId = responseData.data.dataId
                        self.sleepTime = responseData.data.sleepTime
                        self.fellAsleepTime = responseData.data.fellAsleepTime
                        self.awakeTime = responseData.data.awakeTime
                        self.timeOnBed = responseData.data.timeOnBed
                        self.badSleepReason = String(responseData.data.badAwakeReason ?? "")
                    } else {
                        print("Failed to fetch daily sleep analysis: \(responseData.message)")
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
        let dataId: String
        let sleptAt: String
        let score: Int
        let badAwakeReason: String?
        let awakeTime: String
        let fellAsleepTime: String
        let sleepTime: String
        let timeOnBed: String
    }

    // 날짜 형식화 함수
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 원하는 날짜 형식
        return formatter.string(from: date)
    }

    // 현재 시 추출 함수
    static func formatHour(_ date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        return String(format: "%02d", hour) // 두 자리로 포맷팅
    }

    // 현재 분 추출 함수
    static func formatMinute(_ date: Date) -> String {
        let minute = Calendar.current.component(.minute, from: date)
        return String(format: "%02d", minute) // 두 자리로 포맷팅
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}

