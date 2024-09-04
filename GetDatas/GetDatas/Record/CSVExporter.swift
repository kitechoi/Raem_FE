//import Foundation
//import UIKit
//
//class CSVExporter: ObservableObject {
//    @Published var isPresentingActivityController = false // UIActivityViewController가 이미 표시되고 있는지 확인하기 위한 플래그
//
//    static let shared = CSVExporter()
//    
//    private init() {}
//
//    func exportToCSV(fileName: String, data: String, completion: @escaping (URL?) -> Void) {
//        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//        
//        do {
//            try data.write(to: path, atomically: true, encoding: .utf8)
//            print("CSV file created at: \(path)")
//            DispatchQueue.main.async { // Ensure completion is called on main thread
//                completion(path)
//            }
//        } catch {
//            print("Failed to create CSV file: \(error.localizedDescription)")
//            DispatchQueue.main.async { // Ensure completion is called on main thread
//                completion(nil)
//            }
//        }
//    }
//
//    func presentActivityController(from viewController: UIViewController, fileURL: URL) {
//        DispatchQueue.main.async { // Ensure UI code runs on the main thread
//            guard !self.isPresentingActivityController else { return } // 이미 Activity Controller가 표시 중이면 중복 호출 방지
//            
//            self.isPresentingActivityController = true // 표시 중으로 설정
//            
//            // 권한 및 접근 가능 여부를 확인합니다.
//            guard FileManager.default.fileExists(atPath: fileURL.path) else {
//                print("File does not exist at path: \(fileURL.path)")
//                self.isPresentingActivityController = false
//                return
//            }
//            
//            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//            
//            activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
//                DispatchQueue.main.async {
//                    self?.isPresentingActivityController = false // 닫힐 때 표시 중 상태 해제
//                }
//            }
//            
//            viewController.present(activityVC, animated: true)
//        }
//    }
//}
