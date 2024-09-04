import Foundation
import UIKit
import Combine

class DreamAiPredictionManager: ObservableObject {
    @Published var predictionResults: [(timestamp: String, isSleeping: Bool, probability: Double)] = []
    
    private var previousSleepStates: [(timestamp: String, isSleeping: Bool)] = []
    private let aiProcessor = DreamAiProcessor()
    
    func processReceivedData(_ data: [MeasurementData]) {
//        clearPredictions()  // 이전 예측 결과를 삭제
        
        aiProcessor.performPrediction(data: data) { isSleeping, probability, timestamp in
            DispatchQueue.main.async {
//                print("...DreamAi 호출...")
                self.predictionResults.append((timestamp: timestamp, isSleeping: isSleeping, probability: probability))
                // 데이터 받을 때마다 자는지 안자는지 체크
                self.nowSleepState(isSleeping: isSleeping, timestamp: timestamp)
                
                // 연속 n회 수면 중으로 판단되면, 블루투스로 신호를 전달
                self.continuedSleepings(isSleeping: isSleeping, timestamp: timestamp)
            }
        }
    }
    func clearPredictions() {
        predictionResults.removeAll()
        previousSleepStates.removeAll()
    }
    
    // 실시간으로 자는지 안 자는지 확인하는 함수
    private func nowSleepState(isSleeping: Bool, timestamp: String) {
        let logMessage = "DreamAi 예측 결과:"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        if let nowState = predictionResults.last {
            print("\(logMessage) \(nowState) //예측 수행 시각: \(formattedDate)")
            
            // 예측 윈도우에서 첫 번째와 마지막 튜플의 시간만 출력
//            let window = aiProcessor.lastPredictionWindow
//            if let firstTuple = window.first, let lastTuple = window.last {
//                print("예측 윈도우의 첫 번째 튜플 시각: \(firstTuple.timestamp)")
//                print("예측 윈도우의 마지막 튜플 시각: \(lastTuple.timestamp)")
//            }
        } else {
            print("\(logMessage) 예측 결과가 없습니다. \(formattedDate)")
        }
    }

    // 현조 블루투스 기기로 신호보낼 때 사용할 함수
    // 첫 연속 수면 체크 함수
    private func continuedSleepings(isSleeping: Bool, timestamp: String) {
        let consecutiveCount = 3    // 연속 횟수 상수 설정. consecutiveCount가 3일 시 == 3번 연속 호출인지를 확인함.
        
        // 최근 상태를 저장
        previousSleepStates.append((timestamp: timestamp, isSleeping: isSleeping))
        
        // fifo 상태 업데이트
        if previousSleepStates.count > consecutiveCount {
            previousSleepStates.removeFirst()
        }
        
        // 연속된 상태가 모두 수면 상태인지 확인
        if previousSleepStates.count == consecutiveCount {
            let allSleeping = previousSleepStates.allSatisfy { $0.isSleeping }
            
            if allSleeping {
                if let firstSleepingTimestamp = previousSleepStates.first?.timestamp {
                    print("연속 \(consecutiveCount)번 이상 사용자가 수면 상태")
                    print("잠든 1번째 타임스탬프: \(firstSleepingTimestamp)")
                }
            }
        }
    }


    func exportPredictionsToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        let userName = "yeon"
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
