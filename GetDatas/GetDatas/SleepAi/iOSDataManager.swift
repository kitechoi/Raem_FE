//import WatchConnectivity
//
//class iOSDataManager: NSObject, WCSessionDelegate {
//    
//    private var sleepStagePredictor: SleepStagePredictor
//
//    override init() {
//        self.sleepStagePredictor = SleepStagePredictor()
//        super.init()
//        setupWatchConnectivity()
//    }
//    
//    private func setupWatchConnectivity() {
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
//    }
//    
//    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
//        do {
//            let receivedData = try JSONDecoder().decode([MeasurementData].self, from: messageData)
//            for data in receivedData {
//                NotificationCenter.default.post(name: .newMeasurementData, object: nil, userInfo: ["data": data])
//            }
//        } catch {
//            print("Failed to decode received data: \(error.localizedDescription)")
//        }
//    }
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        // WCSession 활성화 완료 시 처리
//    }
//    
//    // 필수 메서드 1: 비활성화 시 호출
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        // 이 메서드에서 필요한 추가 작업을 수행할 수 있습니다. 비워 두어도 무방합니다.
//    }
//    
//    // 필수 메서드 2: 비활성화된 세션이 해제될 때 호출
//    func sessionDidDeactivate(_ session: WCSession) {
//        // 이 메서드에서 필요한 추가 작업을 수행할 수 있습니다. 비워 두어도 무방합니다.
//    }
//}
