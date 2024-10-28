import Foundation
import UIKit
import Combine
import CoreML
import UserNotifications

class StageAiPredictionManager: ObservableObject {
    @Published var predictions: [StageAiPredictionResult] = []
    private var model: StageAi_MyTabularClassifier
    private let windowSize90 = 90
    private let windowSize30 = 30
    private var alarmTime: Date?  // 알람 시각
    private var wakeUpBufferMinutes: Int = 30  // 기상 시간 여분
    private var timer: Timer?  // 알람 시각을 체크할 타이머
    private var isPredictionPaused_StageAi = false // 예측 중지 플래그
    private var bleManager: BLEManager
    @Published var doesAiAlarmTurnedOn = false
    
    // DateFormatter는 매번 생성하지 않고 한번 생성해서 사용
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current  // 로컬 시간대로 설정
        return formatter
    }()
    
    init(bleManager: BLEManager) {
        self.model = try! StageAi_MyTabularClassifier(configuration: MLModelConfiguration())
        self.bleManager = bleManager
        self.model = try! StageAi_MyTabularClassifier(configuration: MLModelConfiguration())
        
        // 초기화 시 UserDefaults에서 알람 시간 불러오기
        loadAlarmTime()
        startTimerForPredictionCheck()
        requestNotificationPermission()
    }

    // 알람 시간과 여분 시간 설정
    func setAlarmTime(alarmTime: Date, wakeUpBufferMinutes: Int) {
        self.alarmTime = alarmTime
        self.wakeUpBufferMinutes = wakeUpBufferMinutes
        UserDefaults.standard.set(alarmTime, forKey: "savedAlarmTime")
        UserDefaults.standard.set(wakeUpBufferMinutes, forKey: "savedWakeUpBufferMinutes")
        print("알람 시각이 \(formattedLocalTime(for: alarmTime))로 설정되었습니다. \(wakeUpBufferMinutes)분 전 예측을 수행합니다.")
    }

    // UserDefaults에서 알람 시간 로드
    private func loadAlarmTime() {
        if let savedAlarmTime = UserDefaults.standard.object(forKey: "savedAlarmTime") as? Date,
           let savedWakeUpBufferMinutes = UserDefaults.standard.object(forKey: "savedWakeUpBufferMinutes") as? Int {
            self.alarmTime = savedAlarmTime
            self.wakeUpBufferMinutes = savedWakeUpBufferMinutes
            print("저장된 알람 시각이 \(formattedLocalTime(for: savedAlarmTime))로 로드되었습니다. \(savedWakeUpBufferMinutes)분 전 예측을 수행합니다.")
        }
    }

    // 예측 체크를 위한 타이머 시작
    private func startTimerForPredictionCheck() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard self != nil else { return }
            // 로직 추가할 수 있음
        }
    }

    func predictionTimeCheck(_ data: [MeasurementData]) {
        guard let alarmTime = self.alarmTime else {
            print("알람 시각이 설정되지 않았습니다.")
            return
        }

        let currentTime = Date()
        let predictionTime = alarmTime.addingTimeInterval(TimeInterval(-wakeUpBufferMinutes * 60))
        let currentHourMinute = getHourMinute(from: currentTime)
        let predictionHourMinute = getHourMinute(from: predictionTime)
        let alarmHourMinute = getHourMinute(from: alarmTime)

        // Debugging: 시, 분만 출력
        print("currentTime (hour:min):", timeFormatter.string(from: currentHourMinute))
        print("predictionTime (hour:min):", timeFormatter.string(from: predictionHourMinute))
        print("alarmTime (hour:min):", timeFormatter.string(from: alarmHourMinute))

        // 시, 분만 비교
        if currentHourMinute >= predictionHourMinute && currentHourMinute <= alarmHourMinute {
            print("알람 시각이 맞습니다. 예측을 수행합니다.")
            processReceivedData(data)
        } else {
            print("아직 예측을 수행할 시간이 아닙니다. 아직 \(timeFormatter.string(from: predictionHourMinute)) 이전입니다.")
        }
    }

    // 시, 분 형식으로 시간 포맷터 설정
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current  // 로컬 시간대로 설정
        return formatter
    }()

    // 시, 분만을 반환하는 메서드
    private func getHourMinute(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return calendar.date(from: components) ?? date
    }


    func processReceivedData(_ data: [MeasurementData]) {
        guard data.count >= windowSize90 else {
            print("StageAi 데이터가 충분하지 않습니다.")
            return
        }
        guard !isPredictionPaused_StageAi else {
            print("StageAi는 이미 렘을 찾아서 중지 중입니다.")
            return
        }
        performPrediction(data)
    }
    
    func resetPredictionState() {
        isPredictionPaused_StageAi = false
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
                    // 렘(5)일 경우, 알람울리기
                    if predictedLevel == 5 {
                        self.detectedRem()  // 렘수면 시 알림 관련 함수
//                        self.isPredictionPaused_StageAi = true // 렘수면 시 플래그로써 예측이 수행되지 않게 함. 데모 위하여 주석처리
                        print("렘을 찾았으니, 앞으로 예측을 중지합니다")
                        
                        let red: Double = UserDefaults.standard.double(forKey: "red")
                        let green: Double = UserDefaults.standard.double(forKey: "green")
                        let blue: Double = UserDefaults.standard.double(forKey: "blue")
                        let brightness: Double = UserDefaults.standard.double(forKey: "brightness")
                        let duration: Int = UserDefaults.standard.integer(forKey: "TurnOnDuration")
                        print("\(red), \(green), \(blue), \(brightness)")
                        self.bleManager.turnOnAlarm("\(duration),\(red * brightness),\(green * brightness),\(blue * brightness),alarm,80")
                    
                        self.doesAiAlarmTurnedOn = true
                    }
                }

            } catch {
                print("예측 실패: \(error.localizedDescription)")
            }
        }
    }

    func detectedRem() {
        print("렘입니다. 예측시각: \(self.formattedCurrentTime())")
        
        // 로컬 알림 생성
        let content = UNMutableNotificationContent()
        content.title = "기상 알림"
        content.body = "렘수면입니다. 일어나세요."
        content.sound = UNNotificationSound.default
        
        // 알림을 즉시 표시하도록 설정
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // 알림 추가
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("알림 울림 실패: \(error.localizedDescription)")
            } else {
                print("알림 울림 성공")
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
        return formattedLocalTime(for: Date())
    }

    // 로컬 시간대로 시간 형식을 반환하는 메서드
    private func formattedLocalTime(for date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func exportPredictionsToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current  // 로컬 시간대로 설정
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
    // 알림 권한 요청 함수
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            } else if granted {
                print("알림 권한이 허용되었습니다.")
            } else {
                print("알림 권한이 거부되었습니다.")
            }
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
