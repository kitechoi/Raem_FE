import SwiftUI
import HealthKit

enum DisplayState {
    case allData
    case timeSorted
    case levelSorted
}

struct SleepDataView: View {
    @EnvironmentObject var sessionManager: SessionManager // 이메일 사용을 위한 SessionManager
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var temporaryStartDate = Date()
    @State private var temporaryEndDate = Date()
    @State private var isStartDatePickerPresented = false
    @State private var isEndDatePickerPresented = false
    @State private var isSortedByLevel = false
    @State private var sleepData: [HKSleepAnalysis] = []
    @State private var displayState: DisplayState = .allData

    private let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "수면 데이터")

            HStack {
                VStack(alignment: .leading) {
                    Text("시작 날짜")
                    Button(action: {
                        temporaryStartDate = startDate
                        isStartDatePickerPresented.toggle()
                    }) {
                        HStack {
                            Text("\(formatDateInput(startDate))")
                            Spacer()
                            Image(systemName: "calendar")
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $isStartDatePickerPresented) {
                        VStack {
                            DatePicker(
                                "시작 날짜",
                                selection: $temporaryStartDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                            .padding()
                            
                            Button("확인") {
                                startDate = temporaryStartDate
                                isStartDatePickerPresented = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text("끝 날짜")
                    Button(action: {
                        temporaryEndDate = endDate
                        isEndDatePickerPresented.toggle()
                    }) {
                        HStack {
                            Text("\(formatDateInput(endDate))")
                            Spacer()
                            Image(systemName: "calendar")
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $isEndDatePickerPresented) {
                        VStack {
                            DatePicker(
                                "끝 날짜",
                                selection: $temporaryEndDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                            .padding()
                            
                            Button("확인") {
                                endDate = temporaryEndDate
                                isEndDatePickerPresented = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            
            Button(action: {
                loadSleepData()
                displayState = .allData
            }) {
                Text("수면 데이터 불러오기")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            HStack {
                Button(action: {
                    sortByTime()
                    displayState = .timeSorted
                }) {
                    Text("시간순 정렬")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    sortByLevel()
                    displayState = .levelSorted
                }) {
                    Text("수면단계 정렬")
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: exportDataToCSV) {
                    Text("CSV")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            
            List {
                if displayState == .levelSorted {
                    let filteredData = sleepData.filter { $0.level != 2 } // 'Awake' 제거
                    let groupedData = groupAndAggregateSleepData(filteredData)
                    ForEach(groupedData.keys.sorted(), id: \.self) { level in
                        let data = groupedData[level]!
                        VStack(alignment: .leading) {
                            Text("\(data.levelDescription) (\(level))")
                            Text("interval: \(data.count)회")
                            Text("total time: \(formatDuration(data.totalTime))")
                        }
                    }
                } else {
                    let filteredData = sleepData.filter { $0.level != 0 || displayState == .allData } // 'In Bed' 제거 조건 추가
                    ForEach(filteredData) { sleep in
                        VStack(alignment: .leading) {
                            Text("start: \(formatFullDate(sleep.startDate))")
                            Text("end  : \(formatFullDate(sleep.endDate))")
                            Text("level: \(sleep.levelDescription) (\(sleep.level))")
                        }
                    }
                }
            }
        }
        .onAppear {
           requestHealthAuthorization()
       }
        .navigationBarBackButtonHidden(true)
        
    }

    func exportDataToCSV() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedEndDate = dateFormatter.string(from: endDate)
        
        // 사용자 이메일 또는 기본 사용자 이름 결정
        let userEmailOrDefaultName = sessionManager.isLoggedIn ? sessionManager.email : "사용자"
        
        // 파일 이름을 "이메일(끝나는날짜).csv" 또는 "사용자(끝나는날짜).csv"로 설정
        let fileName = "\(userEmailOrDefaultName)(\(formattedEndDate)).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var csvText = "start,end,level,level(Int)\n"
        
        // 현재 표시된 데이터를 기반으로 CSV 생성
        let filteredData: [HKSleepAnalysis]
        switch displayState {
        case .allData:
            filteredData = sleepData
        case .timeSorted:
            filteredData = sleepData.filter { $0.level != 0 }
        case .levelSorted:
            filteredData = sleepData.filter { $0.level != 2 }
            csvText = "level,interval,total time\n"
        }
        
        if displayState == .levelSorted {
            let groupedData = groupAndAggregateSleepData(filteredData)
            for level in groupedData.keys.sorted() {
                let data = groupedData[level]!
                let newLine = "\(data.levelDescription),\(data.count)회,\(formatDuration(data.totalTime))\n"
                csvText.append(contentsOf: newLine)
            }
        } else {
            for sleep in filteredData.sorted(by: { $0.startDate < $1.startDate }) {
                let newLine = "\(formatFullDate(sleep.startDate)),\(formatFullDate(sleep.endDate)),\(sleep.levelDescription),\(sleep.level)\n"
                csvText.append(contentsOf: newLine)
            }
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            shareCSV(path: path)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
    }

    func shareCSV(path: URL) {
        let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)

        // 현재 활성화된 윈도우 씬을 가져옵니다.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }


    private func formatDateInput(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func requestHealthAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let typesToShare: Set<HKSampleType> = []
            let typesToRead: Set<HKObjectType> = [
                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            ]
            
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if !success {
                    // Handle error.
                }
            }
        }
    }
    
    private func loadSleepData() {
        guard #available(iOS 16.0, *) else {
            showUnsupportedVersionAlert()
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            guard let results = results as? [HKCategorySample], error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                sleepData = results.map { sample in
                    let sleepLevel = HKSleepAnalysis(sample: sample)
                    return sleepLevel
                }
                isSortedByLevel = false
            }
        }
        
        healthStore.execute(query)
    }
    
    private func showUnsupportedVersionAlert() {
        let alert = UIAlertController(title: "지원하지 않는 버전", message: "이 기능은 iOS 16 이상에서만 사용할 수 있습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        // 현재 활성화된 윈도우 씬을 가져옵니다.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    
    private func sortByTime() {
        sleepData.sort { $0.startDate < $1.startDate }
        isSortedByLevel = false
    }
    
    private func sortByLevel() {
        isSortedByLevel = true
    }
    
    private func groupAndAggregateSleepData(_ data: [HKSleepAnalysis]) -> [Int: (count: Int, totalTime: TimeInterval, levelDescription: String)] {
        var result = [Int: (count: Int, totalTime: TimeInterval, levelDescription: String)]()
        
        for item in data {
            if result[item.level] == nil {
                result[item.level] = (count: 0, totalTime: 0, levelDescription: item.levelDescription)
            }
            result[item.level]!.count += 1
            result[item.level]!.totalTime += item.endDate.timeIntervalSince(item.startDate)
        }
        
        return result
    }
}

struct HKSleepAnalysis: Identifiable, Hashable {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var level: Int
    
    var levelDescription: String {
        switch level {
        case 0: return "In Bed"
        case 1: return "Unspecified"
        case 2: return "Awake"
        case 3: return "Deep"
        case 4: return "Core"
        case 5: return "Rem"
        default: return "Unknown"
        }
    }
    
    init(sample: HKCategorySample) {
        self.startDate = sample.startDate
        self.endDate = sample.endDate
        self.level = sample.value
    }
}

struct SleepDataView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDataView()
            .environmentObject(SessionManager())
    }
}
