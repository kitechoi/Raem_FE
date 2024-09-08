import Foundation
import UIKit
import Combine
import CoreML

class StageAiPredictionManager: ObservableObject {
    @Published var predictions: [StageAiPredictionResult] = []
    private var model: StageAi_MyTabularClassifier
    private let windowSize90 = 90
    private let windowSize30 = 30

    init() {
        self.model = try! StageAi_MyTabularClassifier(configuration: MLModelConfiguration())
    }
    
    func processReceivedData(_ data: [MeasurementData]) {
        guard data.count >= windowSize90 else {
            return
        }

        performPrediction(data)
    }

    private func performPrediction(_ data: [MeasurementData]) {
        let window90 = Array(data.suffix(windowSize90))
        let window30 = Array(data.suffix(windowSize30))
        let firstTimestamp = window90.first?.timestamp ?? "N/A"
        let lastTimestamp = window90.last?.timestamp ?? "N/A"
        
        if let input = preprocessDataForPrediction(window90, window30: window30) {
            do {
                let predictionOutput = try model.prediction(input: input)
                let predictedLevel = predictionOutput.level_Int_
                let predictedProbability = predictionOutput.level_Int_Probability
                let lastTimestampdata = lastTimestamp
                
                let result = StageAiPredictionResult(
                    timestamp: formattedCurrentTime(),
                    predictedLevel: predictedLevel,
                    predictedProbability: predictedProbability
                )
                DispatchQueue.main.async {
                    self.predictions.append(result)
                    print("StageAi 예측 결과: \(predictedLevel), 확률: \(predictedProbability), 마지막데이터: \(lastTimestampdata) 예측시각: \(self.formattedCurrentTime())")
                }

            } catch {
                print("예측 실패: \(error.localizedDescription)")
            }
        }
    }

    private func preprocessDataForPrediction(_ window90: [MeasurementData], window30: [MeasurementData]) -> StageAi_MyTabularClassifierInput? {
        guard window90.count == windowSize90 else {
            print("StageAi 데이터가 충분하지 않아 예측을 수행할 수 없습니다.")
            return nil
        }

        let heartRates90 = window90.map { $0.heartRate }
        let accelerationX90 = window90.map { $0.accelerationX }
        let accelerationY90 = window90.map { $0.accelerationY }
        let accelerationZ90 = window90.map { $0.accelerationZ }
        
        return preprocessIncomingData(
            heartRates: heartRates90,
            accelerationX: accelerationX90,
            accelerationY: accelerationY90,
            accelerationZ: accelerationZ90
        )
    }

    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }

    func exportPredictionsToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        let userName = "user"
        let fileName = "\(userName)_StageAi_(\(date)).csv"
        
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        var csvText = "Timestamp,Predicted Level,Probabilities\n"
        
        for entry in predictions {
            let probabilitiesText = entry.predictedProbability.map { "\($0.key): \($0.value * 100)%" }.joined(separator: "; ")
            let newLine = "\(entry.timestamp),\(entry.predictedLevel),\(probabilitiesText)\n"
            csvText.append(contentsOf: newLine)
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV file: \(error)")
            return nil
        }
    }

    func clearPredictions() {
        predictions.removeAll()
    }
}

struct StageAiPredictionResult: Identifiable {
    var id = UUID()
    var timestamp: String
    var predictedLevel: Int64
    var predictedProbability: [Int64: Double]
}
