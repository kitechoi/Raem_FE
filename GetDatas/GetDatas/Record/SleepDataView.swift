import SwiftUI

// SleepData 모델 정의
struct SleepData: Codable, Identifiable {
    var id = UUID()
    var date: String
    var sleepDuration: Double
    var sleepLevel: String  // 수면 레벨 (e.g., "in bed", "rem", "core", "deep")
}

// SleepDataView 정의
struct SleepDataView: View {
    @State private var sleepData: [SleepData] = []
    @State private var groupedData: [(String, Double)] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isGroupedByLevel = false
    
    var body: some View {
        VStack {
            // 버튼 섹션
            VStack {
                Button(action: {
                    fetchSleepData()
                }) {
                    Text("수면 데이터 불러오기")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                HStack {
                    Button(action: {
                        groupBySleepLevel()
                    }) {
                        Text("수면 레벨로 묶기")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        sortByDate()
                    }) {
                        Text("시간 순서로 정렬")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
            
            // 데이터 목록 섹션
            VStack {
                if !sleepData.isEmpty {
                    List {
                        if isGroupedByLevel {
                            ForEach(groupedData, id: \.0) { (sleepLevel, totalDuration) in
                                Section(header: Text(sleepLevel.capitalized).font(.headline)) {
                                    VStack(alignment: .leading) {
                                        Text("총 수면 시간: \(formatDuration(totalDuration))")
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        } else {
                            ForEach(sleepData) { data in
                                VStack(alignment: .leading) {
                                    Text("Date: \(data.date)")
                                    Text("Sleep Level: \(data.sleepLevel.capitalized)")
                                    Text("Sleep Duration: \(data.sleepDuration) hours")
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                } else {
                    Text("No sleep data available")
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .navigationTitle("수면 데이터")
    }
    
    private func fetchSleepData() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sevenDaysAgoString = dateFormatter.string(from: sevenDaysAgo)
        
        guard let url = URL(string: "http://www.raem.shop/api/sleep?startDate=\(sevenDaysAgoString)") else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "데이터 불러오기에 실패했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([SleepData].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.sleepData = decodedData
                        self.sortByDate()  // 기본적으로 시간 순서로 정렬
                    }
                } catch {
                    DispatchQueue.main.async {
                        alertMessage = "데이터 디코딩에 실패했습니다: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
    
    private func sortByDate() {
        sleepData.sort { $0.date < $1.date }
        isGroupedByLevel = false
    }
    
    private func groupBySleepLevel() {
        let grouped = Dictionary(grouping: sleepData, by: { $0.sleepLevel })
        groupedData = grouped.map { (key, value) in
            let totalDuration = value.reduce(0) { $0 + $1.sleepDuration }
            return (key, totalDuration)
        }
        isGroupedByLevel = true
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)
        return "\(hours)시간 \(minutes)분"
    }
}

struct SleepDataView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDataView()
    }
}
