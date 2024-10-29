import SwiftUI
import Charts

// 서버에서 가져오는 SleepEntry 구조체 정의
struct SleepEntry: Identifiable {
    let id = UUID()
    let sleptAt: String
    let score: Int
    let sleepTime: String // 총 수면 시간 (HH:mm:ss 형식 또는 X시간 Y분 형식)
}

struct WeeklyView: View {
    @State private var sleepEntries: [SleepEntry] = []
    @State private var averageSleepTime: String = "N/A" // 주당 평균 수면 시간을 저장
    @State private var loadingData: Bool = false
    @State private var errorMessage: String? = nil
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 20) {
                HStack {
                    Text("수면 별점")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                
                if loadingData {
                    ProgressView("Loading data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 170)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(height: 170)
                } else if sleepEntries.isEmpty {
                    Text("No sleep data available for the selected week.")
                        .foregroundColor(.gray)
                        .frame(height: 170)
                } else {
                    Chart {
                        ForEach(sleepEntries) { entry in
                            BarMark(
                                x: .value("weekDay", convertDateToKoreanWeekday(entry.sleptAt)),
                                y: .value("score", entry.score),
                                width: 20
                            )
                            .foregroundStyle(Color.deepNavy)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .stride(by: 1)) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.gray)
                            AxisTick()
                                .foregroundStyle(Color.gray)
                            AxisValueLabel()
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.gray)
                            AxisTick()
                                .foregroundStyle(Color.gray)
                            AxisValueLabel()
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .chartYScale(domain: 0...5)
                    .frame(height: 170)
                }
            }
            .padding(.vertical, 8)
            .onAppear {
                fetchWeeklySleepAnalysis()
            }
            
            // 주당 평균 수면 시간 표시
            VStack(spacing: 20) {
                HStack {
                    Text("이번 주 평균 수면 시간")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 16) {
                                Image("moon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(averageSleepTime)
                                        .font(Font.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Average Sleep Time")
                                        .font(Font.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
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
    }
    
    // 서버에서 주간 수면 분석 데이터를 가져오는 함수
    func fetchWeeklySleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token found")
            self.errorMessage = "Access token not found"
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/analysis?range=weekly")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        loadingData = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingData = false
                
                if let error = error {
                    print("Error fetching weekly sleep analysis: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load data. Please try again."
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No HTTP response received")
                    self.errorMessage = "Failed to load data. No response received."
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    print("Non-200 HTTP response received: \(httpResponse.statusCode)")
                    self.errorMessage = "Failed to load data. Received status code \(httpResponse.statusCode)."
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self.errorMessage = "Failed to load data. No data received."
                    return
                }

                do {
                    let responseData = try JSONDecoder().decode(WeeklySleepResponse.self, from: data)
                    if responseData.isSuccess, let list = responseData.data?.list {
                        self.sleepEntries = list.map {
                            SleepEntry(
                                sleptAt: $0.sleptAt,
                                score: $0.score,
                                sleepTime: $0.sleepTime
                            )
                        }
                        // 평균 수면 시간을 계산
                        calculateAverageSleepTime(entries: list)
                    } else {
                        print("Failed to fetch weekly sleep analysis: \(responseData.message)")
                        self.errorMessage = "Error: \(responseData.message)"
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response JSON: \(jsonString)")
                    }
                    self.errorMessage = "Failed to decode data. Please try again."
                }
            }
        }.resume()
    }

    // 주당 평균 수면 시간을 계산하는 함수
    func calculateAverageSleepTime(entries: [SleepEntryResponse]) {
        let validSleepTimes = entries.filter { !$0.sleepTime.isEmpty }
        let totalMinutes = validSleepTimes.map { convertTimeToMinutes($0.sleepTime) }.reduce(0, +)
        
        if !validSleepTimes.isEmpty {
            let averageMinutes = totalMinutes / validSleepTimes.count
            self.averageSleepTime = convertMinutesToHoursMinutesAndSeconds(averageMinutes)
        } else {
            self.averageSleepTime = "N/A"
        }
    }

    // "HH:mm:ss" 또는 "X시간 Y분" 형식의 시간을 분으로 변환하는 함수
    func convertTimeToMinutes(_ timeString: String) -> Int {
        if timeString.contains("시간") && timeString.contains("분") {
            // "X시간 Y분" 형식 처리
            let hourPart = timeString.components(separatedBy: "시간").first.flatMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? 0
            let minutePart = timeString.components(separatedBy: "시간").last?.components(separatedBy: "분").first.flatMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? 0
            return hourPart * 60 + minutePart
        } else {
            // "HH:mm:ss" 형식 처리
            let components = timeString.split(separator: ":").compactMap { Int($0) }
            guard components.count == 3 else {
                print("Invalid time format: \(timeString)")  // 형식 오류 디버깅
                return 0
            }
            return components[0] * 60 + components[1]
        }
    }

    // 분을 "HH:mm:ss" 형식의 문자열로 변환하는 함수
    func convertMinutesToHoursMinutesAndSeconds(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, 0) // 초는 항상 0으로 설정
    }

    // sleptAt의 날짜를 한국어 요일로 변환하는 함수
    func convertDateToKoreanWeekday(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 설정
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE" // 요일 형식으로 변환
            return dateFormatter.string(from: date) // 요일을 반환 (예: "월요일")
        } else {
            return dateString // 변환 실패 시 원래 날짜 반환
        }
    }
}

// 서버 응답 구조체 정의
struct WeeklySleepResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: WeeklySleepData?
}

struct WeeklySleepData: Decodable {
    let list: [SleepEntryResponse]
}

struct SleepEntryResponse: Decodable {
    let sleptAt: String
    let score: Int
    let sleepTime: String
}

