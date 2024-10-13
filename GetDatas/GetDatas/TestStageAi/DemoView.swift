import SwiftUI

struct DemoView: View {
    @StateObject private var predictionManager = StageAiPredictionManager()
    @State private var predictions: [StageAiPredictionResult] = []
    @State private var measurementData: [MeasurementData] = []
    @State private var timer: Timer? = nil
    @State private var currentDataStartIndex = 0

    var body: some View {
        VStack {
            Text("데모 페이지")
                .font(.largeTitle)
                .padding()
            
            Text("이 페이지는 기능을 시연하기 위한 데모 페이지입니다.")
                .font(.subheadline)
                .padding()
            
            if predictions.isEmpty {
                Text("예측 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(predictions) { prediction in
                    VStack(alignment: .leading) {
                        Text("Timestamp: \(prediction.timestamp)")
                            .font(.headline)
                        Text("Predicted Level: \(prediction.predictedLevel)")
                            .font(.subheadline)
                        Text("Probabilities: \(formatProbabilities(prediction.predictedProbability))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startPredictionCycle() // 페이지 로드 시 즉시 예측 시작
        }
        .onDisappear {
            timer?.invalidate() // 페이지를 벗어날 때 타이머 중지
        }
    }
    
    private func startPredictionCycle() {
        if let data = loadCSVData(fileName: "test_cropped_realtime_data(0757)") {
            measurementData = data
            predictions = []
            currentDataStartIndex = 0

            performPrediction() // 첫 예측 수행

            // 1분 간격으로 예측을 반복 수행
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                performPrediction()
            }
        } else {
            print("CSV 파일을 불러올 수 없습니다.")
        }
    }
    
    private func performPrediction() {
        let endIndex = currentDataStartIndex + 89
        guard endIndex < measurementData.count else {
            print("데이터가 부족하여 예측을 종료합니다.")
            timer?.invalidate()
            return
        }

        // 현재 시작 인덱스부터 90개의 데이터를 선택
        let dataSlice = Array(measurementData[currentDataStartIndex...endIndex])
        
        // 예측 수행
        predictionManager.processReceivedData(dataSlice)
        
        // 예측 결과가 즉시 UI에 반영되도록 비동기적으로 처리
        DispatchQueue.main.async {
            if let latestPrediction = predictionManager.predictions.last {
                var updatedPrediction = latestPrediction
                // dataSlice의 마지막 타임스탬프를 예측 결과에 반영
                updatedPrediction.timestamp = dataSlice.last?.timestamp ?? "N/A"
                predictions.append(updatedPrediction)
            }
        }

        // 다음 예측을 위해 시작 인덱스를 30씩 이동
        currentDataStartIndex += 30
    }

    
    private func loadCSVData(fileName: String) -> [MeasurementData]? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("\(fileName) 파일을 찾을 수 없습니다.")
            return nil
        }
        
        do {
            let csvData = try String(contentsOf: fileURL)
            let rows = csvData.split(separator: "\n").dropFirst()
            var measurementData: [MeasurementData] = []
            
            for row in rows {
                let columns = row.split(separator: ",")
                if columns.count >= 5,
                   let heartRate = Double(columns[1]),
                   let accX = Double(columns[2]),
                   let accY = Double(columns[3]),
                   let accZ = Double(columns[4]) {
                    
                    let data = MeasurementData(
                        heartRate: heartRate,
                        accelerationX: accX,
                        accelerationY: accY,
                        accelerationZ: accZ,
                        timestamp: String(columns[0])
                    )
                    measurementData.append(data)
                }
            }
            return measurementData
        } catch {
            print("CSV 파일 로드 오류: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func formatProbabilities(_ probabilities: [Int64: Double]) -> String {
        return probabilities.map { "\($0.key): \($0.value * 100)%" }.joined(separator: ", ")
    }
}
