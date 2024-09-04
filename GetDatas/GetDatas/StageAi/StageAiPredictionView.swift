import Foundation
import SwiftUI

struct StageAiPredictionView: View {
    @ObservedObject var stageAiPredictionManager: StageAiPredictionManager

    // 현재 시각을 문자열로 변환하는 함수
    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 원하는 날짜 및 시간 형식 설정
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        VStack {
            Text("StageAi 예측 결과")
                .font(.largeTitle)
                .padding()

            if stageAiPredictionManager.predictions.isEmpty {
                Text("예측 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(stageAiPredictionManager.predictions) { prediction in
                    VStack(alignment: .leading) {
                        Text("Timestamp: \(prediction.timestamp)")
                            .font(.headline)
                        Text("Predicted Level: \(prediction.predictedLevel)")
                            .font(.subheadline)
                        Text("Probabilities: \(formatProbabilities(prediction.predictedProbability))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }

            Spacer()
            
//            Button("StageAi 예측 결과 CSV로 내보내기") {
//                if let csvURL = stageAiPredictionManager.exportPredictionsToCSV() {
//                    let activityVC = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let rootVC = windowScene.windows.first?.rootViewController {
//                        rootVC.present(activityVC, animated: true)
//                    }
//                }
//            }
//            .padding()
//            .background(Color.orange)
//            .foregroundColor(.white)
//            .cornerRadius(10)
        }
        .padding()
    }
    
    // 예측 확률을 포맷팅하는 함수
    private func formatProbabilities(_ probabilities: [Int64: Double]) -> String {
        return probabilities.map { "\($0.key): \($0.value * 100)%" }.joined(separator: ", ")
    }
}
