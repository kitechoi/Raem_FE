//
//  StageAiProcesser.swift
//  GetDatas
//
//  Created by m on 9/4/24.
//  연

import Foundation

// 표준편차(변동성)를 계산하는 함수
func calculateVariability(values: [Double], windowSize: Int) -> [Double] {
    guard values.count >= windowSize else { return [] }
    var result: [Double] = []
    
    for i in 0...(values.count - windowSize) {
        let window = values[i..<i+windowSize]
        let mean = window.reduce(0, +) / Double(windowSize)
        let variance = window.map { pow($0 - mean, 2) }.reduce(0, +) / Double(windowSize)
        result.append(sqrt(variance))
    }
    return result
}

// 이동 평균을 계산하는 함수
func calculateMovingAverage(values: [Double], windowSize: Int) -> [Double] {
    guard values.count >= windowSize else { return [] }
    var result: [Double] = []
    
    for i in 0...(values.count - windowSize) {
        let window = values[i..<i+windowSize]
        let average = window.reduce(0, +) / Double(windowSize)
        result.append(average)
    }
    return result
}

// 가속도계 데이터의 변동성을 계산하는 함수
func calculateAccVariability(accelerationX: [Double], accelerationY: [Double], accelerationZ: [Double], windowSize: Int) -> [Double] {
    let variabilityX = calculateVariability(values: accelerationX, windowSize: windowSize)
    let variabilityY = calculateVariability(values: accelerationY, windowSize: windowSize)
    let variabilityZ = calculateVariability(values: accelerationZ, windowSize: windowSize)
    
    // 각 윈도우의 변동성 합 계산
    var accVariabilitySum: [Double] = []
    for i in 0..<min(variabilityX.count, variabilityY.count, variabilityZ.count) {
        accVariabilitySum.append(variabilityX[i] + variabilityY[i] + variabilityZ[i])
    }
    return accVariabilitySum
}

// 상호작용 피처를 생성하는 함수
func createInteractionFeatures(heartRateVariability: [Double], accVariabilitySum: [Double]) -> ([Double], [Double]) {
    var hrVarXAccVarSum: [Double] = []
    var hrVarDivAccVarSum: [Double] = []
    
    for i in 0..<min(heartRateVariability.count, accVariabilitySum.count) {
        hrVarXAccVarSum.append(heartRateVariability[i] * accVariabilitySum[i])
        hrVarDivAccVarSum.append(heartRateVariability[i] / (accVariabilitySum[i] + 1e-5))  // 0으로 나눔 방지
    }
    
    return (hrVarXAccVarSum, hrVarDivAccVarSum)
}

// 실시간 데이터를 전처리하는 함수
func preprocessIncomingData(heartRates: [Double], accelerationX: [Double], accelerationY: [Double], accelerationZ: [Double]) -> StageAi_MyTabularClassifierInput? {
    let windowSize90 = 90
    let windowSize30 = 30
    
    // 심박수 피처 계산
    let heartRateVariability90 = calculateVariability(values: heartRates, windowSize: windowSize90).last ?? 0.0
    let heartRateMovingAverage90 = calculateMovingAverage(values: heartRates, windowSize: windowSize90).last ?? 0.0
    let heartRateMovingAverage30 = calculateMovingAverage(values: heartRates, windowSize: windowSize30).last ?? 0.0
    
    // 가속도계 피처 계산
    let accVariabilitySum = calculateAccVariability(accelerationX: accelerationX, accelerationY: accelerationY, accelerationZ: accelerationZ, windowSize: windowSize90).last ?? 0.0
    
    // 상호작용 피처 계산
    let (hrVarXAccVarSum, hrVarDivAccVarSum) = createInteractionFeatures(heartRateVariability: [heartRateVariability90], accVariabilitySum: [accVariabilitySum])
    
    // 모델 입력 데이터 생성
    let input = StageAi_MyTabularClassifierInput(
        heart_rate: heartRates.last ?? 0.0,
        heart_rate_variability: heartRateVariability90,
        heart_rate_moving_average_90: heartRateMovingAverage90,
        heart_rate_moving_average_30: heartRateMovingAverage30,
        acc_variability_sum: accVariabilitySum,
        hr_var_x_acc_var_sum: hrVarXAccVarSum.last ?? 0.0,
        hr_var_div_acc_var_sum: hrVarDivAccVarSum.last ?? 0.0
    )
    
    return input
}
