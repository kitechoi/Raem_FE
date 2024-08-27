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
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    @Published var receivedData: [MeasurementData] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let receivedData = try JSONDecoder().decode([MeasurementData].self, from: messageData)
            
            DispatchQueue.main.async {
                self.receivedData.append(contentsOf: receivedData)
            }
        } catch {
            print("Failed to decode received data: \(error.localizedDescription)")
        }
    }

    func exportDataToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        
        // Set the file name as "Name(Date).csv"
        let fileName = "eeeewwww(\(date)).csv"
        
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
    
    
    func printHeartRates() {
        for entry in receivedData {
            if(entry.heartRate < 60) {
                //red
                //bleManager.controllLED("255,0,0")
                print("red : 60이하, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 65 && entry.heartRate < 70) {
                //orange
                //bleManager.controllLED("255,128,0")
                print("orange : 65이상 70미만, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 70 && entry.heartRate < 75) {
                //yellow
                //bleManager.controllLED("255,255,0")
                print("yellow : 70이상 75미만, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 75 && entry.heartRate < 80) {
                //green
                //bleManager.controllLED("0,255,0")
                print("green : 75이상 80미만, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 80 && entry.heartRate < 85) {
                //blue
                //bleManager.controllLED("0,128,255")
                print("blue : 80이상 85미만, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 85 && entry.heartRate < 90) {
                //navy
                //bleManager.controllLED("0,0,255")
                print("navy : 85이상 90미만, 현재 심박수: \(entry.heartRate)")
            } else if (entry.heartRate >= 90 && entry.heartRate < 95) {
                //purple
                //bleManager.controllLED("128,0,255")
                
                print("purple")
            } else if (entry.heartRate >= 95 && entry.heartRate < 100) {
                //white
                //bleManager.controllLED("0,0,0")
                print("white")
            } else {
                //pink
                //bleManager.controllLED("255,0,255")
                print("pink")
            }
        }
        //bleManager.controllLED("0,0,0")
        print("black")
    }
    
    
}


struct RecordView: View {
    @ObservedObject var connectivityManager = iPhoneConnectivityManager()
    
    var body: some View {
        VStack {
            CustomTopBar(title: "실시간 데이터")
            
            if !connectivityManager.receivedData.isEmpty {
                HStack {
                    Button("CSV로 내보내기") {
                        if let csvURL = connectivityManager.exportDataToCSV() {
                            let activityVC = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                rootVC.present(activityVC, animated: true)
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
        .onAppear {
            connectivityManager.printHeartRates()
        }
    }
}
