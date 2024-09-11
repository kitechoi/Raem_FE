import SwiftUI
import Charts
import HealthKit

struct DailyView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var popUpVisible: Bool = false
    @State private var selectedReason: Reason? = nil
    @State private var rating: Int = 2
    @State private var sleptAt: String = "2024-08-31"
    @State private var sleepHour: String = "09"
    @State private var sleepMinute: String = "41"
    
    @State private var sleepData: [HKSleepAnalysis] = []
    @State private var loadingData: Bool = false
    
    @State private var sleepTime: String = ""
    @State private var fellAsleepTime: String = ""
    @State private var awakeTime: String = ""
    @State private var timeOnBed: String = ""
    
    private let healthStore = HKHealthStore()
    
    enum Reason {
        case caffeine
        case exercise
        case stress
        case alcohol
        case smartphone
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
                        Button(action: {
                            popUpVisible = true
                        }) {
                            Text("더보기")
                                .font(.system(size: 17))
                                .foregroundColor(.deepNavy)
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
                                
                                Text("\(sleepHour)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black) +
                                Text("시")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black) +
                                Text(" \(sleepMinute)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black) +
                                Text("분")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            Text("\(sleptAt)")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Text("어제보다 46분 더 주무셨네요.")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                            .padding(.bottom, 12)
                        
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
                            Spacer()
                            VStack(alignment: .leading) {
                                HStack(spacing: 45) {
                                    VStack(alignment: .leading, spacing: 4) {
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
                                    }
                                    .padding(.trailing, 10)
                                    
                                    VStack(spacing: 4) {
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
                                    }
                                }
                                .padding(.top, 20)
                                
                                HStack(spacing: 45) {
                                    VStack(alignment: .leading, spacing: 4) {
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
                                    .padding(.trailing, 10)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
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
                                .padding(.top, 25)
                                .padding(.bottom, 18)
                            }
                            Spacer()
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
                                popUpVisible = false
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
    
    private func loadSleepData() {
        guard #available(iOS 16.0, *) else {
            return
        }
        
        let startDateComponents = DateComponents(year: 2024, month: 8, day: 22, hour: 12, minute: 0)
        let startDate = Calendar.current.date(from: startDateComponents)!
        
        let endDateComponents = DateComponents(year: 2024, month: 8, day: 23, hour: 12, minute: 0)
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
                        self.sleepTime = responseData.data.sleepTime
                        self.fellAsleepTime = responseData.data.fellAsleepTime
                        self.awakeTime = responseData.data.awakeTime
                        self.timeOnBed = responseData.data.timeOnBed
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
        let sleptAt: String
        let score: Int
        let badAwakeReason: String?
        let awakeTime: String
        let fellAsleepTime: String
        let sleepTime: String
        let timeOnBed: String
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}


