//import CoreML
//import Foundation
//
//class SleepStagePredictor {
//    private var model: ClassifierModel0823_last
//    private var dataBuffer: [(heartRate: Double, accelMagnitude: Double)] = []
//
//    init() {
//        model = try! ClassifierModel0823_last()
//        setupDataNotification()
//    }
//
//    private func setupDataNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMeasurementData(_:)), name: .newMeasurementData, object: nil)
//    }
//
//    @objc private func handleNewMeasurementData(_ notification: Notification) {
//        guard let data = notification.userInfo?["data"] as? MeasurementData else { return }
//        addData(heartRate: data.heartRate, accelX: data.accelerationX, accelY: data.accelerationY, accelZ: data.accelerationZ)
//    }
//
//    func addData(heartRate: Double, accelX: Double, accelY: Double, accelZ: Double) {
//        let accelMagnitude = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ)
//        dataBuffer.append((heartRate: heartRate, accelMagnitude: accelMagnitude))
//
//        print("Data count: \(dataBuffer.count)")  // 데이터 개수 확인용 로그
//
//        if dataBuffer.count == 30 {
//            predictSleepStage()
//            dataBuffer.removeFirst()  // 슬라이딩 윈도우처럼 가장 오래된 데이터 제거
//        }
//    }
//
//    private func predictSleepStage() {
//        do {
//            print("Starting prediction process...")
//            
//            let heartRateArray = dataBuffer.map { $0.heartRate }
//            let accelMagnitudeArray = dataBuffer.map { $0.accelMagnitude }
//            
//            // 예측을 위한 입력 데이터 생성
//            var totalHeartRate: Double = 0
//            var totalAccelMagnitude: Double = 0
//            
//            for i in 0..<30 {
//                totalHeartRate += heartRateArray[i]
//                totalAccelMagnitude += accelMagnitudeArray[i]
//            }
//            
//            let avgHeartRate = totalHeartRate / 30
//            let avgAccelMagnitude = totalAccelMagnitude / 30
//            
//            print("Average Heart Rate: \(avgHeartRate), Average Acceleration Magnitude: \(avgAccelMagnitude)")
//            
//            let prediction = try model.prediction(Heart_Rate: avgHeartRate, Acceleration_Magnitude: avgAccelMagnitude)
//            let predictedStage = prediction.level_Int_  // 예측된 수면 단계
//            
//            print("Predicted Sleep Stage: \(predictedStage)")
//            
//            NotificationCenter.default.post(name: .predictedSleepStage, object: nil, userInfo: ["stage": predictedStage])
//        } catch {
//            print("Failed to predict sleep stage: \(error.localizedDescription)")
//        }
//    }
//
//}
//
//extension Notification.Name {
//    static let newMeasurementData = Notification.Name("newMeasurementData")
//    static let predictedSleepStage = Notification.Name("predictedSleepStage")
//}
