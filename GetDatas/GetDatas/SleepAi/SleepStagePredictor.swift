import CoreML
import Foundation

class SleepStagePredictor {
    private var model: ClassifierModel0823_30block // 모델 인스턴스
    private var dataBuffer: [(heartRate: Double, accelMagnitude: Double)] = []

    init() {
        // 모델 초기화
        model = ClassifierModel0823_30block()
        setupDataNotification()
    }

    private func setupDataNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMeasurementData(_:)), name: .newMeasurementData, object: nil)
    }

    @objc private func handleNewMeasurementData(_ notification: Notification) {
        guard let data = notification.userInfo?["data"] as? MeasurementData else { return }
        addData(heartRate: data.heartRate, accelX: data.accelerationX, accelY: data.accelerationY, accelZ: data.accelerationZ)
    }

    func addData(heartRate: Double, accelX: Double, accelY: Double, accelZ: Double) {
        // 가속도 크기 계산
        let accelMagnitude = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ)
        
        // 데이터 버퍼에 추가
        dataBuffer.append((heartRate: heartRate, accelMagnitude: accelMagnitude))
        
        // 버퍼가 30개의 데이터를 갖추면 예측 수행
        if dataBuffer.count == 30 {
            predictSleepStage()
            dataBuffer.removeFirst() // 가장 오래된 데이터 제거 (슬라이딩 윈도우)
        }
    }

    private func predictSleepStage() {
        // 30개의 데이터를 모델 입력 형식에 맞게 변환
        let inputArray = dataBuffer.map { NSNumber(value: $0.heartRate + $0.accelMagnitude) }
        let inputMLArray = try! MLMultiArray(shape: [30], dataType: .double)

        for (index, value) in inputArray.enumerated() {
            inputMLArray[index] = value
        }

        // 모델 예측 수행
        do {
            let prediction = try model.prediction(input: inputMLArray)
            let predictedStage = prediction.sleepStage  // 예측된 수면 단계
            print("Predicted Sleep Stage: \(predictedStage)")
            NotificationCenter.default.post(name: .predictedSleepStage, object: nil, userInfo: ["stage": predictedStage])
        } catch {
            print("Failed to predict sleep stage: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let predictedSleepStage = Notification.Name("predictedSleepStage")
}
