import Foundation
import Combine

class DreamAiViewModel: ObservableObject {
    @Published var predictions: [(time: String, isSleeping: Bool, probability: Double)] = []
    
    private let aiProcessor = DreamAiProcessor()
    
    func performPrediction(data: [MeasurementData]) {
        aiProcessor.performPrediction(data: data) { isSleeping, probability in
            let currentTime = self.currentTimestamp()
            let prediction = (time: currentTime, isSleeping: isSleeping, probability: probability)
            DispatchQueue.main.async {
                self.predictions.append(prediction)
            }
        }
    }
    
    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
