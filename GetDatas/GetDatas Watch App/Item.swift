import Foundation
import HealthKit
import CoreMotion
import AVFoundation

class HealthDataViewModel: ObservableObject {
    let healthStore = HKHealthStore()
    let motionManager = CMMotionManager()
    var audioRecorder: AVAudioRecorder?
    
    var timer: Timer?
    
    @Published var output: String = ""
    
    var heartRate: Double = 0.0
    var accelerometerData: CMAccelerometerData?
    var ambientNoiseLevel: Float = 0.0
    
    private var heartRateQuery: HKQuery?
    
    func requestAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if !success {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func startMonitoring() {
        startHeartRateMonitoring()
        startAccelerometerMonitoring()
        startNoiseMonitoring()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateOutput), userInfo: nil, repeats: true)
    }
    
    func stopMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        motionManager.stopAccelerometerUpdates()
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.handleHeartRateSamples(samples)
        }
        
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.handleHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    func handleHeartRateSamples(_ samples: [HKQuantitySample]) {
        guard let sample = samples.last else { return }
        heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
    }
    
    func startAccelerometerMonitoring() {
        motionManager.startAccelerometerUpdates()
    }
    
    func startNoiseMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { allowed in
                if allowed {
                    self.startRecording()
                }
            }
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    @objc func updateOutput() {
        if let data = motionManager.accelerometerData {
            accelerometerData = data
        }
        
        audioRecorder?.updateMeters()
        ambientNoiseLevel = abs(audioRecorder?.averagePower(forChannel: 0) ?? 0.0)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd / HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let outputString = """
        \(dateString)
        심박수 : \(String(format: "%.2f", self.heartRate))
        가속도계 : \(String(format: "%.2f", self.accelerometerData?.acceleration.x ?? 0.0)), \(String(format: "%.2f", self.accelerometerData?.acceleration.y ?? 0.0)), \(String(format: "%.2f", self.accelerometerData?.acceleration.z ?? 0.0))
        주변 데시벨 : \(String(format: "%.2f", self.ambientNoiseLevel))
        -------------------------------
        """
        
        DispatchQueue.main.async {
            self.output = outputString
            print(outputString)
        }
    }
}
