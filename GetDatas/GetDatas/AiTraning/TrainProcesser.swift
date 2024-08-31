import Foundation
import CoreML
import CreateML

class TrainProcessor {
    
    func preprocessAndTrain(recordFilePath: String, userFilePath: String) {
        // 파일을 접근 가능한 디렉터리로 복사
        let recordURL = URL(fileURLWithPath: recordFilePath)
        let userURL = URL(fileURLWithPath: userFilePath)
        
        if let copiedRecordURL = copyFileToDocuments(fileName: "record(2024-08-31).csv", from: recordURL),
           let copiedUserURL = copyFileToDocuments(fileName: "사용자(2024-08-31).csv", from: userURL) {
            
            // 복사된 파일 경로로 CSV 파일 로드
            guard let recordData = loadCSV(from: copiedRecordURL.path),
                  let userData = loadCSV(from: copiedUserURL.path) else {
                print("CSV 파일을 로드하는 데 실패했습니다.")
                return
            }

            // CSV 파일에서 데이터가 비어 있는지 확인
            if recordData.isEmpty || userData.isEmpty {
                print("CSV 파일이 비어 있습니다.")
                return
            }

            // 2. Timestamp, start, end 컬럼을 datetime 형식으로 변환
            let processedRecordData = processTimestamps(for: recordData) // 여기서 'processTimestamps' 함수가 호출됨
            let processedUserData = processStartEndTimes(for: userData)
            
            // 3. 특정 Timestamp에 해당하는 level(Int)를 찾고 추가
            let mergedData = mergeRecordWithLevelData(recordData: processedRecordData, userData: processedUserData)
            
            // 4. 필요한 전처리 작업 수행 (수면 단계와 관련된 데이터 분리)
            let (level3Data, nanData) = filterSleepStages(data: mergedData)
            
            // 5. 변동성 계산 수행
            let processedLevel3Data = calculateVariability(for: level3Data)
            let processedNanData = calculateVariability(for: nanData)
            
            // 6. 데이터 합치기 및 재학습 시작
            let combinedData = processedNanData + processedLevel3Data
            saveToCSV(data: combinedData, fileName: "combinedData.csv")
            
            // 7. Core ML 모델 업데이트
            // updateModel(with: combinedData)
        } else {
            print("파일 복사에 실패했습니다.")
        }
    }
    
    func copyFileToDocuments(fileName: String, from sourceURL: URL) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // 보안 스코프 시작
            let _ = sourceURL.startAccessingSecurityScopedResource()
            
            // 만약 파일이 이미 존재한다면 삭제
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            
            print("파일 복사 성공: \(destinationURL.path)")
            sourceURL.stopAccessingSecurityScopedResource()  // 보안 스코프 해제
            return destinationURL
        } catch {
            print("파일 복사 중 오류 발생: \(error.localizedDescription)")
            sourceURL.stopAccessingSecurityScopedResource()  // 보안 스코프 해제
            return nil
        }
    }

    func loadCSV(from filePath: String) -> [[String: String]]? {
        print("시도하는 파일 경로: \(filePath)")  // 파일 경로 출력

        guard let data = try? String(contentsOfFile: filePath) else {
            print("파일을 읽는 데 실패했습니다: \(filePath)")
            return nil
        }
        
        var result: [[String: String]] = []
        let rows = data.components(separatedBy: "\n").filter { !$0.isEmpty }  // 빈 줄 제거
        guard rows.count > 1 else {
            print("CSV 파일이 비어 있습니다: \(filePath)")
            return nil
        }
        
        let headers = rows[0].components(separatedBy: ",")
        
        for row in rows.dropFirst() {
            let values = row.components(separatedBy: ",")
            guard values.count == headers.count else {
                print("잘못된 CSV 형식. 헤더와 값의 수가 일치하지 않습니다: \(row)")
                continue
            }
            
            var rowDict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                rowDict[header] = values[index]
            }
            result.append(rowDict)
        }
        
        return result
    }


    func processTimestamps(for data: [[String: String]]) -> [[String: String]] {
        var processedData = data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for index in 0..<processedData.count {
            if let timestampString = processedData[index]["Timestamp"],
               let date = dateFormatter.date(from: timestampString) {
                processedData[index]["Timestamp"] = dateFormatter.string(from: date)
            }
        }
        return processedData
    }
    
    func processStartEndTimes(for data: [[String: String]]) -> [[String: String]] {
        var processedData = data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for index in 0..<processedData.count {
            if let startString = processedData[index]["start"],
               let startDate = dateFormatter.date(from: startString) {
                processedData[index]["start"] = dateFormatter.string(from: startDate)
            }
            if let endString = processedData[index]["end"],
               let endDate = dateFormatter.date(from: endString) {
                processedData[index]["end"] = dateFormatter.string(from: endDate)
            }
        }
        return processedData
    }
    
    func mergeRecordWithLevelData(recordData: [[String: String]], userData: [[String: String]]) -> [[String: String]] {
        var mergedData = recordData
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for index in 0..<mergedData.count {
            if let timestampString = mergedData[index]["Timestamp"],
               let timestamp = dateFormatter.date(from: timestampString) {
                
                if let level = findLevel(for: timestamp, in: userData) {
                    mergedData[index]["level(Int)"] = "\(level)"
                }
            }
        }
        return mergedData
    }
    
    func findLevel(for timestamp: Date, in userData: [[String: String]]) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for entry in userData {
            if let startString = entry["start"],
               let endString = entry["end"],
               let startDate = dateFormatter.date(from: startString),
               let endDate = dateFormatter.date(from: endString),
               startDate <= timestamp, timestamp <= endDate {
                return Int(entry["level(Int)"] ?? "")
            }
        }
        return nil
    }
    
    func filterSleepStages(data: [[String: String]]) -> ([[String: String]], [[String: String]]) {
        var level3Data: [[String: String]] = []
        var nanData: [[String: String]] = []
        
        var isLevel3SectionFound = false
        var isNanSectionFound = false
        
        var currentLevel3Section: [[String: String]] = []
        var currentNanSection: [[String: String]] = []
        
        for i in 0..<data.count {
            if let level = data[i]["level(Int)"] {
                if level == "3" {
                    if !isNanSectionFound, !currentNanSection.isEmpty {
                        nanData = currentNanSection
                        isNanSectionFound = true
                    }
                    currentNanSection.removeAll()
                    
                    currentLevel3Section.append(data[i])
                } else if level == "0" {
                    if !isLevel3SectionFound, !currentLevel3Section.isEmpty {
                        level3Data = currentLevel3Section
                        isLevel3SectionFound = true
                    }
                    currentLevel3Section.removeAll()
                    
                    currentNanSection.append(data[i])
                } else {
                    currentLevel3Section.removeAll()
                    currentNanSection.removeAll()
                }
            }
            
            if isLevel3SectionFound && isNanSectionFound {
                break
            }
        }
        
        if !isLevel3SectionFound, !currentLevel3Section.isEmpty {
            level3Data = currentLevel3Section
        }
        if !isNanSectionFound, !currentNanSection.isEmpty {
            nanData = currentNanSection
        }
        
        return (level3Data, nanData)
    }
    
    func calculateVariability(for data: [[String: String]]) -> [[String: String]] {
        var processedData = data
        let windowSize = 90
        
        func standardDeviation(_ values: [Double]) -> Double {
            guard values.count > 1 else { return 0.0 }
            let mean = values.reduce(0, +) / Double(values.count)
            let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count - 1)
            return sqrt(variance)
        }
        
        let columnsToCalculate = ["Heart Rate", "Acceleration X", "Acceleration Y", "Acceleration Z"]
        
        // 데이터의 길이가 windowSize보다 클 경우에만 계산 수행
        guard processedData.count > windowSize else {
            print("데이터의 길이가 windowSize보다 작아서 변동성을 계산할 수 없습니다.")
            return processedData
        }
        
        for column in columnsToCalculate {
            for index in windowSize..<processedData.count {
                // index가 windowSize보다 크거나 같은 경우에만 슬라이싱을 수행
                if index >= windowSize {
                    let lowerBound = max(0, index - windowSize)  // 하한이 0보다 작지 않도록 보장
                    let window = processedData[lowerBound...index]
                    let values = window.compactMap { Double($0[column] ?? "") }
                    let variability = standardDeviation(values)
                    processedData[index]["\(column)_variability"] = String(format: "%.4f", variability)
                }
            }
        }
        
        return processedData
    }


    func saveToCSV(data: [[String: String]], fileName: String) {
        // 파일 경로 설정
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // 데이터가 비어있는지 확인
        guard let firstRow = data.first else {
            print("저장할 데이터가 없습니다.")
            return
        }
        
        // CSV 파일의 헤더 생성
        let headers = Array(firstRow.keys)
        var csvText = headers.joined(separator: ",") + "\n"
        
        // 각 행을 CSV 형식으로 변환하여 추가
        for row in data {
            let rowText = headers.map { row[$0] ?? "" }.joined(separator: ",")
            csvText += rowText + "\n"
        }
        
        // 파일에 쓰기
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV 파일이 성공적으로 저장되었습니다: \(fileURL.path)")
        } catch {
            print("CSV 파일 저장 중 오류 발생: \(error.localizedDescription)")
        }
    }

    
//    func convertToMLDataTable(data: [[String: String]]) throws -> MLDataTable {
//        // 데이터를 MLDataTable로 변환
//        var columns: [String: [MLDataValueConvertible]] = [:]
//        guard let firstRow = data.first else {
//            throw NSError(domain: "Empty Data", code: -1, userInfo: nil)
//        }
//        
//        for key in firstRow.keys {
//            if let doubleValues = data.compactMap({ Double($0[key] ?? "") }) as [Double]? {
//                columns[key] = doubleValues
//            }
//        }
//        
//        return try MLDataTable(dictionary: columns)
//    }
//    
//    func updateModel(with trainingData: [[String: String]]) {
//        guard let modelURL = Bundle.main.url(forResource: "DreamDetector_TabularClassifier", withExtension: "mlmodelc") else {
//            print("모델 파일을 찾을 수 없습니다.")
//            return
//        }
//
//        do {
//            // 데이터를 MLDataTable 형식으로 변환
//            let trainingDataTable = try convertToMLDataTable(data: trainingData)
//            
//            // MLDataTable을 개별 MLFeatureProvider로 변환
//            var featureProviders: [MLFeatureProvider] = []
//            for row in trainingDataTable.rows {
//                featureProviders.append(try MLDictionaryFeatureProvider(dictionary: row.dictionary))
//            }
//            
//            // MLArrayBatchProvider 생성
//            let batchProvider = MLArrayBatchProvider(array: featureProviders)
//            
//            let configuration = MLModelConfiguration()
//
//            // 모델 업데이트 작업 생성
//            let updateTask = try MLUpdateTask(forModelAt: modelURL, trainingData: batchProvider, configuration: configuration) { context in
//                // 업데이트 완료 후 새 모델 저장
//                let updatedModelURL = FileManager.default.temporaryDirectory.appendingPathComponent("UpdatedDreamDetector.mlmodelc")
//                do {
//                    try context.model.write(to: updatedModelURL)
//                    print("모델이 성공적으로 업데이트되어 저장되었습니다: \(updatedModelURL.path)")
//                } catch {
//                    print("모델 저장 오류: \(error)")
//                }
//            }
//
//            // 학습 진행 상황을 수신하는 핸들러
//            updateTask.progressHandlers = MLUpdateProgressHandlers(
//                forEvents: [.miniBatchEnd, .epochEnd],
//                progressHandler: { context in
//                    if let progress = context.metrics[.lossValue] as? Double {
//                        print("학습 중 진행 상황: 손실 값 = \(progress)")
//                    }
//                },
//                completionHandler: { context in
//                    if context.task.state == .completed {
//                        print("모델 업데이트가 완료되었습니다.")
//                    } else if context.task.error != nil {
//                        print("모델 업데이트 중 오류 발생: \(context.task.error!)")
//                    }
//                }
//            )
//
//            // 학습 시작
//            updateTask.resume()
//
//        } catch {
//            print("모델 업데이트 오류: \(error)")
//        }
//    }
}
