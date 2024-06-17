import SwiftUI
import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    var heartRateObserverQuery: HKObserverQuery?
    
    // HealthKit 권한 요청
    func requestAuthorization() {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if success {
                print("HealthKit authorization granted.")
            } else {
                print("HealthKit authorization denied.")
            }
        }
    }
    
    // 수면 데이터 불러오기
    func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis data type is not available.")
            return
        }
        
        // 수면 단계를 정수형에서 문자열로 변환하기 위한 딕셔너리
        let sleepCategoryStrings = [
            0: "In Bed",
            1: "Sleep Unspecified",
            2: "Awake",
            3: "Core",
            4: "Deep",
            5: "REM"
        ]
        
        // 한국 시간대로 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        // 오늘로부터 7일 전의 날짜를 계산
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            print("Failed to calculate 7 days ago date.")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100, sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Failed to fetch sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 수면 데이터 처리
            for sample in samples {
                // 수면 상태가 "inbed"인 경우에는 출력을 건너뜁니다.
                guard sample.value != 0 else {
                    continue
                }
                
                // 가져온 데이터 출력
                print("Start Date: \(dateFormatter.string(from: sample.startDate))")
                print("End Date: \(dateFormatter.string(from: sample.endDate))")
                
                if let stringValue = sleepCategoryStrings[sample.value] {
                    print("Sleep level: \(stringValue) (\(sample.value))")
                } else {
                    print("Sleep value: Unknown")
                }
                
                print("\n------------------------------\n")
            }
        }
        
        healthStore.execute(query)
    }

    
    // 심박수 측정 시작
    func startMeasuringHeartRate() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("Failed to observe heart rate changes: \(error.localizedDescription)")
                return
            }
            
            // Fetch recent heart rate samples
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                guard let samples = samples as? [HKQuantitySample], let heartRateSample = samples.first else {
                    print("No heart rate samples available.")
                    return
                }
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let heartRate = Int(heartRateSample.quantity.doubleValue(for: heartRateUnit))
                print("Observed heart rate changes: \(heartRate) bpm")

            }
            
            self?.healthStore.execute(query)
        }
        
        healthStore.execute(query)
        heartRateObserverQuery = query
        
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
            if success {
                print("Background delivery enabled for heart rate updates.")
            } else {
                print("Failed to enable background delivery for heart rate updates: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }


    // 심박수 측정 정지
    func stopMeasuringHeartRate() {
        if let query = heartRateObserverQuery {
            healthStore.stop(query)
            print("Heart rate observation stopped.")
        }
    }
    
}
