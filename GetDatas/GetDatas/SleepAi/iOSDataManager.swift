import WatchConnectivity

class iOSDataManager: NSObject, WCSessionDelegate {
    private var sleepStagePredictor: SleepStagePredictor

    override init() {
        self.sleepStagePredictor = SleepStagePredictor()
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let receivedData = try JSONDecoder().decode([MeasurementData].self, from: messageData)
            for data in receivedData {
                NotificationCenter.default.post(name: .newMeasurementData, object: nil, userInfo: ["data": data])
            }
        } catch {
            print("Failed to decode received data: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion
    }
    
    // 다른 WCSessionDelegate 메서드도 필요에 따라 구현
}
