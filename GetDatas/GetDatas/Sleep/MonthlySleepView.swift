import SwiftUI
import Charts

struct MonthlySleepEntry: Decodable {
    let tag: String
    let scoreSum: Int
    let inBedSum: String
    let awakeSum: String
    let sleepTimeSum: String // "HH:mm:ss" 형식으로 서버에 저장됨
    let badAwakeReasonsCount: [BadAwakeReason]
    let dataCount: Int
}

struct MonthlySleepData: Identifiable {
    let id = UUID()
    let tag: String
    let avgScore: Double
    let sleepTimeSum: String // 총 수면 시간
    let awakeSum: String // 총 깨어난 시간
    let weekIndex: Int // 순차적으로 1주차, 2주차 등
}

struct MonthlyView: View {
    @State private var monthlySleepData: [MonthlySleepData] = []
    @State private var averageSleepDepth: String = "N/A"
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
                } else if monthlySleepData.isEmpty {
                    Text("No sleep data available for this month.")
                        .foregroundColor(.gray)
                        .frame(height: 170)
                } else {
                    Chart {
                        ForEach(monthlySleepData) { entry in
                            BarMark(
                                x: .value("Week", "\(entry.weekIndex)주차"),
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

            // 이번 달 평균 수면 깊이 섹션
            VStack(spacing: 20) {
                HStack {
                    Text("이번 달 평균 수면 시간")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }

                VStack(alignment: .leading){
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack(spacing: 45) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 16) {
                                        Image("moon")
                                            .resizable()
                                            .frame(width: 24, height: 24)

                                        VStack(alignment: .leading, spacing: 4){
                                            Text(averageSleepDepth)
                                                .font(Font.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Average Sleep Time")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
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
            .onAppear {
                fetchMonthlySleepAnalysis()
            }
        }
    }

    // 서버에서 월간 수면 분석 데이터를 가져오는 함수
    func fetchMonthlySleepAnalysis() {
        guard let accessToken = sessionManager.accessToken else {
            print("No access token found")
            self.errorMessage = "Access token not found"
            return
        }

        let url = URL(string: "https://www.raem.shop/api/sleep/analysis?range=monthly")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        loadingData = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingData = false

                if let error = error {
                    print("Error fetching monthly sleep analysis: \(error.localizedDescription)")
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
                    let responseData = try JSONDecoder().decode(MonthlySleepResponse.self, from: data)
                    if responseData.isSuccess, let list = responseData.data?.dataList {
                        // 각 데이터 항목에 순차적으로 주차를 할당
                        self.monthlySleepData = list.enumerated().map { index, entry in
                            MonthlySleepData(
                                tag: entry.tag,
                                avgScore: Double(entry.scoreSum) / Double(entry.dataCount),
                                sleepTimeSum: entry.sleepTimeSum,
                                awakeSum: entry.awakeSum,
                                weekIndex: index + 1 // 1부터 시작하는 주차
                            )
                        }

                        // 유효한 sleepTimeSum 필터링 후 계산
                        let validSleepTimes = list.filter { $0.sleepTimeSum != "00:00:00" && !$0.sleepTimeSum.isEmpty }
                        let totalSleepTime = validSleepTimes.map { convertTimeToMinutes($0.sleepTimeSum) }.reduce(0, +)

                        if !validSleepTimes.isEmpty {
                            let averageSleepTimeInMinutes = totalSleepTime / validSleepTimes.count
                            self.averageSleepDepth = convertMinutesToHoursMinutesAndSeconds(averageSleepTimeInMinutes)
                        } else {
                            self.averageSleepDepth = "N/A" // 유효한 데이터가 없으면 N/A 처리
                        }

                    } else {
                        print("Failed to fetch monthly sleep analysis: \(responseData.message)")
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
}

// 서버 응답 구조체 정의
struct MonthlySleepResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: MonthlySleepDataResponse?
}

struct MonthlySleepDataResponse: Decodable {
    let type: String
    let dataList: [MonthlySleepEntry]
}

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyView()
    }
}

