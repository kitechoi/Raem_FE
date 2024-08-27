import SwiftUI
import WatchConnectivity

struct MeasurementData: Codable, Identifiable {
    var id = UUID()
    var heartRate: Double
    var accelerationX: Double
    var accelerationY: Double
    var accelerationZ: Double
    var timestamp: String
}

class iPhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedData: [MeasurementData] = []
    var bleManager: BLEManager
    
    init(bleManager: BLEManager) {
        self.bleManager = bleManager
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let receivedData = try JSONDecoder().decode([MeasurementData].self, from: messageData)
            DispatchQueue.main.async {
                self.receivedData.append(contentsOf: receivedData)
                self.printHeartRates() // 데이터가 로드될 때마다 심박수를 평가하고 출력
            }
        } catch {
            print("Failed to decode received data: \(error.localizedDescription)")
        }
    }

    func printHeartRates() {
        for entry in receivedData {
            if entry.heartRate < 60 {
                bleManager.controllLED("255,0,0")
                print("red : 60이하, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 65 && entry.heartRate < 70 {
                bleManager.controllLED("255,128,0")
                print("orange : 65이상 70미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 70 && entry.heartRate < 75 {
                bleManager.controllLED("255,255,0")
                print("yellow : 70이상 75미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 75 && entry.heartRate < 80 {
                bleManager.controllLED("0,255,0")
                print("green : 75이상 80미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 80 && entry.heartRate < 85 {
                bleManager.controllLED("0,128,255")
                print("blue : 80이상 85미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 85 && entry.heartRate < 90 {
                bleManager.controllLED("0,0,255")
                print("navy : 85이상 90미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 90 && entry.heartRate < 95 {
                bleManager.controllLED("128,0,255")
                print("purple : 90이상 95미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 95 && entry.heartRate < 100 {
                bleManager.controllLED("255,255,255")
                print("white : 95이상 100미만, 현재 심박수: \(entry.heartRate)")
            } else {
                bleManager.controllLED("255,0,255")
                print("pink : 100이상, 현재 심박수: \(entry.heartRate)")
            }
        }
        bleManager.controllLED("Done")
        print("black : 모든 심박수 처리 완료")
    }
    
    func exportDataToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        
        let fileName = "record(\(date)).csv"
        
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        var csvText = "Timestamp,Heart Rate,Acceleration X,Acceleration Y,Acceleration Z\n"
        
        for entry in receivedData {
            let newLine = "\(entry.timestamp),\(entry.heartRate),\(entry.accelerationX),\(entry.accelerationY),\(entry.accelerationZ)\n"
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
    
    func clearReceivedData() {
        receivedData.removeAll()
    }
}

struct RecordView: View {
    @EnvironmentObject var bleManager: BLEManager
    @ObservedObject var connectivityManager = iPhoneConnectivityManager(bleManager: BLEManager())
    
    var body: some View {
        VStack {
            CustomTopBar(title: "실시간 데이터")
            
            if !connectivityManager.receivedData.isEmpty {
                HStack {
                    Button("CSV로 내보내기") {
                        if let csvURL = connectivityManager.exportDataToCSV() {
                            DispatchQueue.main.async {
                                let activityVC = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first?.rootViewController {
                                    if rootVC.presentedViewController == nil {
                                        rootVC.present(activityVC, animated: true)
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            rootVC.present(activityVC, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("데이터 삭제하기") {
                        connectivityManager.clearReceivedData()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            List(connectivityManager.receivedData) { entry in
                VStack(alignment: .leading) {
                    Text("Timestamp: \(entry.timestamp)")
                    Text("Heart Rate: \(entry.heartRate, specifier: "%.0f") BPM")
                    Text("Acceleration: X: \(entry.accelerationX, specifier: "%.2f")")
                    Text("Y: \(entry.accelerationY, specifier: "%.2f")")
                    Text("Z: \(entry.accelerationZ, specifier: "%.2f")")
                }
                .padding(.vertical, 5)
            }
        }
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
    }
}
