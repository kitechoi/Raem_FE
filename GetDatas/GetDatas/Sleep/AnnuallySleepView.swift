import SwiftUI
import Charts

// API 응답에서 사용할 구조체 정의
struct AnnuallySleepEntry: Decodable {
    let tag: String
    let scoreSum: Int
    let inBedSum: String
    let awakeSum: String
    let sleepTimeSum: String // 총 수면 시간 (HH:mm:ss 형식)
    let badAwakeReasonsCount: [BadAwakeReason]
    let dataCount: Int
}

struct AnnuallySleepData: Identifiable {
    let id = UUID()
    let tag: String
    let avgScore: Double
}

struct AnnuallyView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var annuallySleepData: [AnnuallySleepData] = []
    @State private var averageSleepTime: String = "N/A" // 연도별 평균 수면 시간을 저장
    @State private var sleepPattern: String = "수면 패턴 정보를 가져오는 중입니다..."
    @State private var improvement: String = "개선 사항 정보를 가져오는 중입니다..."
    @State private var loadingData: Bool = false
    @State private var errorMessage: String? = nil
    
    // 서버와 연결된 인증 토큰 등을 관리하기 위한 SessionManager 사용
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
                } else if annuallySleepData.isEmpty {
                    Text("No sleep data available for this year.")
                        .foregroundColor(.gray)
                        .frame(height: 170)
                } else {
                    Chart {
                        ForEach(annuallySleepData) { entry in
                            BarMark(
                                x: .value("Month", entry.tag),
                                y: .value("Score", entry.avgScore),
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
                fetchAnnuallySleepAnalysis()
                loadSleepAnalysis()  // 수면 패턴 및 개선 사항 데이터를 가져옴
            }

            // 연도별 평균 수면 시간을 표시하는 섹션
            VStack(spacing: 20) {
                HStack {
                    Text("올해 평균 수면 시간")
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
            
            // "2024 수면 레포트" 섹션
            VStack(spacing: 20) {
                HStack {
                    Text("2024 수면 레포트")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("전체 수면 패턴")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    
                    Text(sleepPattern)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray)
                    
                    HStack {
                        Text("개선 사항")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    Text(improvement)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray)
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
    
    // 서버에서 연간 수면 분석 데이터를 가져오는 함수
    func fetchAnnuallySleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token found")
            self.errorMessage = "Access token not found"
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/analysis?range=annually")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        loadingData = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingData = false
                
                if let error = error {
                    print("Error fetching annually sleep analysis: \(error.localizedDescription)")
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
                    let responseData = try JSONDecoder().decode(AnnuallySleepResponse.self, from: data)
                    if responseData.isSuccess, let list = responseData.data?.dataList {
                        self.annuallySleepData = list.map {
                            AnnuallySleepData(
                                tag: $0.tag,
                                avgScore: Double($0.scoreSum) / Double($0.dataCount)
                            )
                        }
                        // 평균 수면 시간을 계산
                        calculateAverageSleepTime(entries: list)
                    } else {
                        print("Failed to fetch annually sleep analysis: \(responseData.message)")
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

    // 연도별 평균 수면 시간을 계산하는 함수
    func calculateAverageSleepTime(entries: [AnnuallySleepEntry]) {
        let validSleepTimes = entries.filter { !$0.sleepTimeSum.isEmpty }
        let totalMinutes = validSleepTimes.map { convertTimeToMinutes($0.sleepTimeSum) }.reduce(0, +)
        
        if !validSleepTimes.isEmpty {
            let averageMinutes = totalMinutes / validSleepTimes.count
            self.averageSleepTime = convertMinutesToHoursMinutesAndSeconds(averageMinutes)
        } else {
            self.averageSleepTime = "N/A"
        }
    }

    // "HH:mm:ss" 형식의 시간을 분으로 변환하는 함수
    func convertTimeToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        guard components.count == 3 else {
            print("Invalid time format: \(timeString)")  // 형식 오류 디버깅
            return 0
        }
        return components[0] * 60 + components[1] // 시*60 + 분
    }

    // 분을 "HH:mm:ss" 형식의 문자열로 변환하는 함수
    func convertMinutesToHoursMinutesAndSeconds(_ totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, 0) // 초는 항상 0으로 설정
    }
    
    // 서버에서 수면 패턴과 개선 사항을 가져오는 함수
    func loadSleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token found")
            return
        }
        
        guard let url = URL(string: "https://www.raem.shop/api/sleep/analysis/insight") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Non-200 HTTP response received: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseString)")
                    }
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SleepAnalysisResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.isSuccess {
                        self.sleepPattern = decodedResponse.data.sleepPattern
                        self.improvement = decodedResponse.data.improvement
                    } else {
                        print("Server error: \(decodedResponse.message)")
                    }
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
            }
        }.resume()
    }
}

// 서버 응답 구조체 정의
struct AnnuallySleepResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: AnnuallySleepDataResponse?
}

struct AnnuallySleepDataResponse: Decodable {
    let type: String
    let dataList: [AnnuallySleepEntry]
}

struct SleepAnalysisResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: SleepAnalysisData
}

struct SleepAnalysisData: Codable {
    let sleepPattern: String
    let improvement: String
}

struct AnnuallyView_Previews: PreviewProvider {
    static var previews: some View {
        AnnuallyView()
    }
}

