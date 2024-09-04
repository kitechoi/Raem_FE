import CreateML
import CoreML
import Foundation

// 모델 로드 및 테스트 데이터 설정
let model = try MLModel(contentsOf: URL(fileURLWithPath: "MyTabularClassifier_0902(51).mlmodel"))
let testData = try MLDataTable(contentsOf: URL(fileURLWithPath: "sleepStage_tabular_data_with_acc_combined_interaction_28_90.csv"))

// 예측 및 확률 계산
let predictions = try model.predictions(from: testData)

// 예측 결과와 확률 추출
let probabilities = predictions["probability"] as? [String: Double] // 이 부분은 모델에 따라 달라질 수 있습니다.
let threshold = 0.3  // 임계값 설정
var adjustedPredictions: [String] = []

for probability in probabilities {
    if probability["positive"] ?? 0.0 > threshold { // "positive"는 긍정 클래스 레이블 예시
        adjustedPredictions.append("positive")
    } else {
        adjustedPredictions.append("negative")
    }
}
let thresholds = stride(from: 0.0, to: 1.0, by: 0.05) // 0.0부터 1.0까지 0.05 간격으로 임계값 설정
var precisionRecallResults: [(threshold: Double, precision: Double, recall: Double)] = []

for threshold in thresholds {
    // 위에서 작성한 임계값 조정 코드 사용
    // Precision, Recall 계산 후 결과 저장
    let precision = calculatePrecision(predictions: adjustedPredictions, actuals: testData["actualLabelColumnName"])
    let recall = calculateRecall(predictions: adjustedPredictions, actuals: testData["actualLabelColumnName"])
    precisionRecallResults.append((threshold, precision, recall))
}

// 최적의 결과 출력
for result in precisionRecallResults {
    print("Threshold: \(result.threshold), Precision: \(result.precision), Recall: \(result.recall)")
}
