import SwiftUI
import Charts

struct AnnuallyView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var accessToken: String = ""
    @State private var sleepPattern: String = "수면 패턴 정보를 가져오는 중입니다..."
    @State private var improvement: String = "개선 사항 정보를 가져오는 중입니다..."
    @State private var isLoading: Bool = true
    
    let AnnuallyScores: [AnnuallyScores] = [
        .init(label: "1월", avgScore: 3.5),
        .init(label: "2월", avgScore: 4),
        .init(label: "3월", avgScore: 3.3),
        .init(label: "4월", avgScore: 1.25),
        .init(label: "5월", avgScore: 1),
        .init(label: "6월", avgScore: 2),
        .init(label: "7월", avgScore: 0),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            VStack(spacing: 20) {
                HStack {
                    Text("수면 별점")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                
                Chart {
                    ForEach(AnnuallyScores) { score in
                        BarMark(
                            x: .value("month", score.label),
                            y: .value("score", score.avgScore),
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
            .padding(.vertical, 8)
            
            VStack(spacing: 20) {
                HStack {
                    Text("이번 달 평균 수면 깊이")
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
                                            Text("6시간 52분")
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
                                .padding(.trailing, 10)

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
                            .padding(.top, 25)
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
            
            VStack(spacing: 20) {
                HStack {
                    Text("2024 수면 레포트")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12){
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
        .onAppear {
            loadSleepAnalysis()
        }
    }
    
    // 서버로부터 데이터를 가져오는 함수
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

struct AnnuallyScores: Identifiable {
    let id = UUID()
    let label: String
    let avgScore: Double
}

// 서버에서 받은 JSON 데이터에 맞는 구조체
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
