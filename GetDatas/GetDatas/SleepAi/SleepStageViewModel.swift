//import SwiftUI
//import Combine
//
//struct PredictedResult: Identifiable {
//    let id = UUID()
//    let stage: Int64
//    let timestamp: String
//}
//
//class SleepStageViewModel: ObservableObject {
//    @Published var predictedResults: [PredictedResult] = []
//
//    private var cancellable: AnyCancellable?
//
//    init() {
//        // NotificationCenter를 통해 예측된 수면 단계를 구독합니다.
//        cancellable = NotificationCenter.default.publisher(for: .predictedSleepStage)
//            .compactMap { notification -> PredictedResult? in
//                guard let stage = notification.userInfo?["stage"] as? Int64 else { return nil }
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let timestamp = formatter.string(from: Date())
//                return PredictedResult(stage: stage, timestamp: timestamp)
//            }
//            .sink { [weak self] result in
//                self?.predictedResults.append(result)
//            }
//    }
//
//    deinit {
//        cancellable?.cancel()
//    }
//}
