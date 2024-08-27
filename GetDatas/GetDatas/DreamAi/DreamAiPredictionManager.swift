import Foundation
import UIKit
import Combine

class DreamAiPredictionManager: ObservableObject {
    @Published var predictionResults: [(timestamp: String, isSleeping: Bool, probability: Double)] = []
    
    private let aiProcessor = DreamAiProcessor()
    
    func processReceivedData(_ data: [MeasurementData]) {
        aiProcessor.performPrediction(data: data) { isSleeping, probability, timestamp in
            DispatchQueue.main.async {
                self.predictionResults.append((timestamp: timestamp, isSleeping: isSleeping, probability: probability))
            }
        }
    }
    
    func clearPredictions() {
        predictionResults.removeAll()
    }
    
    func exportPredictionsToCSV() -> URL? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: Date())
            
//            let userName = UserDefaults.standard.string(forKey: "userName") ?? UIDevice.current.name
            let userName = "yeon" // 회원가입 확정되면 수정해야.
            let fileName = "\(userName)_DreamAi_(\(date)).csv"
            
            let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            var csvText = "Timestamp,Is Sleeping,Probability\n"
            
            for entry in predictionResults {
                let isSleepingText = entry.isSleeping ? 0 : 1
                let newLine = "\(entry.timestamp),\(isSleepingText),\(entry.probability)\n"
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
}
