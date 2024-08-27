import SwiftUI

struct DreamAiPredictionView: View {
    @ObservedObject var predictionManager: DreamAiPredictionManager
    // 현재 시각을 문자열로 변환하는 함수
    private func formattedCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 원하는 날짜 및 시간 형식 설정
        return dateFormatter.string(from: Date())
    }
    
    var body: some View {
        List {
            ForEach(predictionManager.predictionResults, id: \.timestamp) { result in
                VStack(alignment: .leading) {
                    Text("Timestamp: \(result.timestamp)")
                    Text("Is Sleeping: \(result.isSleeping ? "Yes" : "No")")
                    Text("Probability: \(result.probability, specifier: "%.2f")")
                    Text("예측 터치 시각: \(formattedCurrentTime())") // 예측되는데이터의 시각과 예측수행시각의 차이를 알기 위함
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("예측 결과")
        .toolbar {
            Button("예측 삭제") {
                predictionManager.clearPredictions()
            }
        }
    }
}
