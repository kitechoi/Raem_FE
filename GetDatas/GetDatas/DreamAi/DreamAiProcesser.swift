import Foundation
import CoreML

class DreamAiProcessor {
    var lastPredictionWindow: [MeasurementData] = []
    // 슬라이딩 윈도우에서 변동성 계산 (표준편차 사용)
    func calculateVariability(values: [Double], windowSize: Int = 90) -> [Double] {
        guard values.count >= windowSize else { return [] }
        
        var variabilities: [Double] = []
        
        for i in 0...(values.count - windowSize) {
            let window = Array(values[i..<(i + windowSize)])
            let mean = window.reduce(0, +) / Double(window.count)
            let variance = window.reduce(0) { $0 + pow($1 - mean, 2) } / Double(window.count - 1)
            let stdDeviation = sqrt(variance)
            variabilities.append(stdDeviation)
        }
        
        return variabilities
    }
    
    // 슬라이딩 윈도우에서 특징 추출
    func extractFeaturesFromWindow(_ window: [MeasurementData]) -> DreamDetector_TabularClassifierInput? {
        guard window.count == 90 else { return nil }
        
        let heartRates = window.map { $0.heartRate }
        let accX = window.map { $0.accelerationX }
        let accY = window.map { $0.accelerationY }
        let accZ = window.map { $0.accelerationZ }
        
        // 여기에 모든 윈도우의 변동성을 계산하는 함수 호출
        guard let heartRateVariability = calculateVariability(values: heartRates, windowSize: 90).last else { return nil }
        guard let accXVariability = calculateVariability(values: accX, windowSize: 90).last else { return nil }
        guard let accYVariability = calculateVariability(values: accY, windowSize: 90).last else { return nil }
        guard let accZVariability = calculateVariability(values: accZ, windowSize: 90).last else { return nil }
        
        guard let heartRate = heartRates.last else { return nil }
        
        return DreamDetector_TabularClassifierInput(
            Heart_Rate: heartRate,
            heart_rate_variability: heartRateVariability,
            Acceleration_X_variability: accXVariability,
            Acceleration_Y_variability: accYVariability,
            Acceleration_Z_variability: accZVariability
        )
    }
    
    
    func performPrediction(data: [MeasurementData], completion: @escaping (Bool, Double, String) -> Void) {
        let windowSize = 90

        // 최신 데이터 90개만 사용
        let startIndex = max(0, data.count - windowSize)
        let window = Array(data[startIndex..<data.count])
        lastPredictionWindow = window // 윈도우 데이터 저장
        
        // 90개 미만의 데이터일 경우 예측을 수행하지 않음
        guard window.count == windowSize else {
            print("데이터 90개 미만 -> 예측불가")
            return
        }

        if let features = extractFeaturesFromWindow(window) {
            do {
                let configuration = MLModelConfiguration()
                let model = try DreamDetector_TabularClassifier(configuration: configuration)
                let output = try model.prediction(input: features)
                let isSleeping = output.is_sleeping == 0 // 0이면 잠, 1이면 안잠
                let probability = output.is_sleepingProbability[output.is_sleeping] ?? 0.0
                let timestamp = window.last?.timestamp ?? ""
                
                // 클로저를 통해 결과 반환
                completion(isSleeping, probability, timestamp)
                
            } catch {
                print("Prediction failed: \(error.localizedDescription)")
            }
        }
    }

    // 모델 예측 수행
//    func performPrediction(data: [MeasurementData], completion: @escaping (Bool, Double, String) -> Void) {
//        let windowSize = 90
//        let stepSize = 15    // stepSize 1일 경우 1튜플(0826기준_2초에 1회)마다 예측 수행
//        var index = 0
//        while index + windowSize <= data.count {
//            let window = Array(data[index..<index + windowSize])
//            if let features = extractFeaturesFromWindow(window) {
//                do {
//                    let configuration = MLModelConfiguration()
//                    let model = try DreamDetector_TabularClassifier(configuration: configuration)
//                    let output = try model.prediction(input: features)
//                    let isSleeping = output.is_sleeping == 0 // 0이면 0(잠), 1이면 안잠
//                    let probability = output.is_sleepingProbability[output.is_sleeping] ?? 0.0
//                    let timestamp = window.last?.timestamp ?? ""
//                    
//                    // 클로저를 통해 결과 반환
//                    completion(isSleeping, probability, timestamp)
//                    
//                } catch {
//                    print("Prediction failed: \(error.localizedDescription)")
//                }
//            }
//            index += stepSize
//        }
//    }
}
