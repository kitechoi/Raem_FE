import SwiftUI
import WatchConnectivity

struct MeasurementData: Codable, Identifiable, Equatable {
    var id = UUID()
    var heartRate: Double
    var accelerationX: Double
    var accelerationY: Double
    var accelerationZ: Double
    var timestamp: String
}

class iPhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedData: [MeasurementData] = []
    @Published var predictionManager: DreamAiPredictionManager
    @Published var stageAiPredictionManager = StageAiPredictionManager()
    private let fileManager = FileManager.default
    private let temporaryDirectory = FileManager.default.temporaryDirectory
    //private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var bleManager: BLEManager

    init(bleManager: BLEManager) {
        self.bleManager = bleManager
        self.predictionManager = DreamAiPredictionManager(bleManager: bleManager)
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
//    override init() {
//        super.init()
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
//    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let receivedData = try JSONDecoder().decode([MeasurementData].self, from: messageData)
            DispatchQueue.main.async {
                self.receivedData.append(contentsOf: receivedData)
                print("-------------------")
                print("Received Data Count: \(self.receivedData.count)")  // 데이터 수신 갯수 확인
                self.predictionManager.processReceivedData(self.receivedData)  // DreamAi 수신 후 예측 시작
//                self.stageAiPredictionManager.processReceivedData(self.receivedData) // StageAi
                self.stageAiPredictionManager.predictionTimeCheck(self.receivedData) //
            }
        } catch {
            print("Failed to decode received data: \(error.localizedDescription)")
        }
    }
    // StageAi 예측 시작 시간 체크
    func performStageAiPredictionCheck() {
        if !self.receivedData.isEmpty {
            self.stageAiPredictionManager.predictionTimeCheck(self.receivedData)
        } else {
            print("No data available for Stage AI Prediction.")
        }
    }
    
    // 실시간 데이터 CSV로 내보내기
    func printHeartRates() {
        for entry in receivedData {
            if entry.heartRate < 75 {
                bleManager.controllLED("25.5,0,0")
                print("red : 75이하, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 75 && entry.heartRate < 77 {
                bleManager.controllLED("25.5,12.8,0")
                print("orange : 75이상 77미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 77 && entry.heartRate < 79 {
                bleManager.controllLED("25.5,25.5,0")
                print("yellow : 77이상 79미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 79 && entry.heartRate < 81 {
                bleManager.controllLED("0,25.5,0")
                print("green : 79이상 81미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 81 && entry.heartRate < 83 {
                bleManager.controllLED("0,12.8,25.5")
                print("blue : 81이상 83미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 83 && entry.heartRate < 85 {
                bleManager.controllLED("0,0,25.5")
                print("navy : 83이상 85미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 85 && entry.heartRate < 87 {
                bleManager.controllLED("12.8,0,25.5")
                print("purple : 85이상 87미만, 현재 심박수: \(entry.heartRate)")
            } else if entry.heartRate >= 87 && entry.heartRate < 89 {
                bleManager.controllLED("25.5,25.5,25.5")
                print("white : 87이상 89미만, 현재 심박수: \(entry.heartRate)")
            } else {
                bleManager.controllLED("25.5,0,25.5")
                print("pink : 89이상, 현재 심박수: \(entry.heartRate)")
            }
            sleep(1)
        }
        bleManager.controllLED("0,0,0")
        print("black : 1분간 모인 심박수 처리 완료")
    }
    
    // S3에 데이터를 업로드하는 함수
    func uploadCSVToS3(fileURL: URL, accessToken: String, sleptAt: String, type: String) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://www.raem.shop/api/sleep/data?type=file")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문 생성
        let httpBody = createMultipartBody(fileURL: fileURL, sleptAt: sleptAt, type: type, boundary: boundary)
        
        let session = URLSession.shared
        
        // `uploadTask(with:from:)`를 사용하여 `Data` 객체를 직접 업로드
        let task = session.uploadTask(with: request, from: httpBody) { data, response, error in
            if let error = error {
                print("Error uploading file: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("CSV 파일이 S3에 성공적으로 업로드되었습니다.")
            } else {
                print("파일 업로드 실패. 서버 응답 상태 코드: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("서버 응답: \(responseString)")
                }
            }
        }
        
        task.resume()
    }
    
    // S3에 csv 올릴 때 형식 바꿔주는 함수
    private func createMultipartBody(fileURL: URL, sleptAt: String, type: String, boundary: String) -> Data {
        var body = Data()
        
        // JSON 형식의 `sleptAt` 및 `type` 필드 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"sleptAt\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append("\"\(sleptAt)\"\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append("\"\(type)\"\r\n".data(using: .utf8)!)
        
        // CSV 파일 데이터 추가
        let filename = fileURL.lastPathComponent
        let mimeType = "text/csv"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        if let fileData = try? Data(contentsOf: fileURL) {
            body.append(fileData)
        }
        
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }

       

    func exportDataToCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        
        // 파일 이름 설정
        let fileName = "record(\(date)).csv"
//        let path = documentsDirectory.appendingPathComponent(fileName)
        let path = temporaryDirectory.appendingPathComponent(fileName)
        
        var csvText = "Timestamp,Heart Rate,Acceleration X,Acceleration Y,Acceleration Z\n"
        
        for entry in receivedData {
            let newLine = "\(entry.timestamp),\(entry.heartRate),\(entry.accelerationX),\(entry.accelerationY),\(entry.accelerationZ)\n"
            csvText.append(contentsOf: newLine)
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            print("CSV 파일 생성 성공: \(path.path)")
            return path
        } catch {
            print("Failed to create CSV file: \(error)")
            return nil
        }
    }
    
    // DreamAi 예측 결과 CSV로 내보내기
    func exportDreamAiDataToCSV() -> URL? {
        return predictionManager.exportPredictionsToCSV()
    }

    // StageAi 예측 결과 CSV로 내보내기
    func exportStageAiDataToCSV() -> URL? {
        return stageAiPredictionManager.exportPredictionsToCSV()
    }

    func shareCSV(paths: [URL], completion: @escaping () -> Void) {
        let activityViewController = UIActivityViewController(activityItems: paths, applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            if let presentedVC = rootViewController.presentedViewController {
                presentedVC.dismiss(animated: false) {
                    rootViewController.present(activityViewController, animated: true, completion: completion)
                }
            } else {
                rootViewController.present(activityViewController, animated: true, completion: completion)
            }
        }
    }

    func clearReceivedData() {
        receivedData.removeAll()
    }
}

struct RecordView: View {
    @EnvironmentObject var bleManager: BLEManager
    @StateObject private var connectivityManager: iPhoneConnectivityManager
    @EnvironmentObject var sessionManager: SessionManager

    init(bleManager: BLEManager) {
        _connectivityManager = StateObject(wrappedValue: iPhoneConnectivityManager(bleManager: bleManager))
    }
    
    
    var body: some View {
        VStack {
            CustomTopBar(title: "실시간 데이터")
            
            if !connectivityManager.receivedData.isEmpty {
                HStack {
                    Button("CSV로 내보내기") {
                        if let csvURL = connectivityManager.exportDataToCSV(),
                           let dreamAiURL = connectivityManager.exportDreamAiDataToCSV(),
                           let stageAiURL = connectivityManager.exportStageAiDataToCSV() {
                            DispatchQueue.main.async {
                                connectivityManager.shareCSV(paths: [csvURL, dreamAiURL, stageAiURL]) {
                                    print("모든 CSV 파일 공유 완료.")
                                }
                            }
                        } else {
                            print("CSV 파일을 불러오지 못했습니다.")
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
                Button("실시간데이터CSV S3로") {
                    uploadCSVToServer(type: "realtime") // 실시간 데이터
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                
                NavigationLink(destination: DreamAiPredictionView(predictionManager: connectivityManager.predictionManager)) {
                    Text("DreamAi 예측 결과 보기")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: StageAiPredictionView(stageAiPredictionManager: connectivityManager.stageAiPredictionManager)) {
                    Text("StageAi 예측 결과 보기")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        
            //                Button("예측 결과 CSV로 내보내기") {
            //                    if let csvURL = predictionManager.exportPredictionsToCSV() {
            //                        let activityVC = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
            //                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            //                           let rootVC = windowScene.windows.first?.rootViewController {
            //                            rootVC.present(activityVC, animated: true)
            //                        }
            //                    }
            //                }
            //                .padding()
            //                .background(Color.orange)
            //                .foregroundColor(.white)
            //                .cornerRadius(10)
            //
            //                NavigationLink(destination: DreamAiPredictionView(predictionManager: predictionManager)) {
            //                    Text("예측 결과 보기")
            //                        .padding()
            //                        .background(Color.orange)
            //                        .foregroundColor(.white)
            //                        .cornerRadius(10)
            //                }
            //            }
            
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
            .onChange(of: connectivityManager.receivedData) {
//                connectivityManager.printHeartRates()
            }
        }
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    // S3에 CSV 업로드 설정 함수
    private func uploadCSVToServer(type: String) {
        guard let csvURL = connectivityManager.exportDataToCSV(),
              let accessToken = sessionManager.accessToken else {
            print("CSV 파일 생성 실패 또는 Access Token이 없습니다.")
            return
        }

        // 저장 시점의 날짜를 yyyy-MM-dd 형식으로 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sleptAt = dateFormatter.string(from: Date())  // 현재 날짜를 yyyy-MM-dd 형식으로 변환

        // `uploadCSVToS3` 메서드를 호출할 때 `sleptAt`을 전달합니다.
        connectivityManager.uploadCSVToS3(fileURL: csvURL, accessToken: accessToken, sleptAt: sleptAt, type: type)
    }

}
