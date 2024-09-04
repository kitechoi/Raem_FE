//
//  StageAiPredictionManager.swift
//  GetDatas
//
//  Created by m on 9/4/24.
//  연

import Foundation
import UIKit
import Combine
import CoreML

class StageAiPredictionManager: ObservableObject {
    @Published var predictions: [StageAiPredictionResult] = []
    private var model: StageAi_MyTabularClassifier
    private var receivedDataBuffer: [MeasurementData] = []  // 수신된 데이터를 저장하는 버퍼
    private let windowSize90 = 90
    private let windowSize30 = 30

    init() {
        // 모델 초기화
        self.model = try! StageAi_MyTabularClassifier(configuration: MLModelConfiguration())
    }
    
    // 수신된 데이터를 처리하여 예측을 수행하는 함수
    func processReceivedData(_ data: [MeasurementData]) {
        guard !data.isEmpty else { return }

        // 수신된 데이터를 버퍼에 추가
        receivedDataBuffer.append(contentsOf: data)
//        print("-------------------")
//        print("Received Data Count: \(receivedDataBuffer.count)")
        
        // 데이터가 90개 미만이면 예측을 수행하지 않음
        if receivedDataBuffer.count < windowSize90 {
//            print("데이터 90개 미만 -> 예측불가")
//            print("데이터가 충분하지 않아 StageAi 예측을 수행할 수 없습니다. 수신된 데이터 수: \(receivedDataBuffer.count)")
            return
        }

        // 최신 90개 데이터만 사용하여 예측 수행
        performPrediction()
    }

    // 예측 수행 함수
    private func performPrediction() {
        // 최신 90개의 데이터만 사용
        let window90 = Array(receivedDataBuffer.suffix(windowSize90))
        let window30 = Array(receivedDataBuffer.suffix(windowSize30))  // 최신 30개의 데이터 사용

        // 데이터 전처리 및 예측 수행
        if let input = preprocessDataForPrediction(window90, window30: window30) {
            do {
                // 예측 수행
                let predictionOutput = try model.prediction(input: input)
                let predictedLevel = predictionOutput.level_Int_
                let predictedProbability = predictionOutput.level_Int_Probability
                
                // 예측 결과 저장
                let result = StageAiPredictionResult(
                    timestamp: formattedCurrentTime(),
                    predictedLevel: predictedLevel,
                    predictedProbability: predictedProbability
                )
                DispatchQueue.main.async {
                    self.predictions.append(result)
                    print("예측 결과: \(predictedLevel), 확률: \(predictedProbability)")
                }

                receivedDataBuffer.removeAll()  // 예측 후 데이터 버퍼 초기화

            } catch {
                print("예측 실패: \(error.localizedDescription)")
            }
        }
    }

    // 수신된 데이터를 전처리하여 모델의 입력 형식으로 변환하는 함수
    private func preprocessDataForPrediction(_ window90: [MeasurementData], window30: [MeasurementData]) -> StageAi_MyTabularClassifierInput? {
        // 90개의 데이터가 있어야만 예측을 수행하도록 한다.
        guard window90.count == windowSize90 else {
            print("데이터가 충분하지 않아 예측을 수행할 수 없습니다.")
            return nil
        }

        let heartRates90 = window90.map { $0.heartRate }
        let accelerationX90 = window90.map { $0.accelerationX }
        let accelerationY90 = window90.map { $0.accelerationY }
        let accelerationZ90 = window90.map { $0.accelerationZ }
        
        let heartRates30 = window30.map { $0.heartRate }
        
        // 데이터 전처리
        return preprocessIncomingData(
            heartRates: heartRates90,
            accelerationX: accelerationX90,
            accelerationY: accelerationY90,
            accelerationZ: accelerationZ90
        )
    }

    // 현재 시각을 문자열로 변환하는 함수
    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    // 예측 결과를 CSV 파일로 내보내는 함수
    func exportPredictionsToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        let userName = "user"  // 예시 사용자 이름
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
    
    // 예측 결과를 모두 지우는 함수
    func clearPredictions() {
        predictions.removeAll()
        receivedDataBuffer.removeAll()
    }
}

// 예측 결과를 저장하기 위한 구조체
struct StageAiPredictionResult: Identifiable {
    var id = UUID()
    var timestamp: String
    var predictedLevel: Int64
    var predictedProbability: [Int64: Double]
}
