import SwiftUI
import SwiftData
import HealthKit
import HealthKitUI

@main
struct GetDatasApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    
    // Healthkit 인증 코드가 있는 객체를 선언해줍니다.
    let service = HealthKitService()
 
    // 수면 데이터에 대한 권한이 허용되어 있는지 확인
    let sleepAnalysisType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    var authorizationStatus: HKAuthorizationStatus = .notDetermined // 초기화 필요
     
    var body: some Scene {
        WindowGroup {
            LoadingView()
        }
        .modelContainer(sharedModelContainer)
    }
    
     init() {
         setup()
         switch authorizationStatus {
             case .notDetermined:
                 // 권한이 아직 요청되지 않음
                 print("권한이 아직 요청되지 않음")
             case .sharingDenied:
                 // 권한 거부됨
                 print("권한 거부됨")
             case .sharingAuthorized:
                 // 권한 부여됨
                 print("권한 부여됨")
             default:
                 break // 기본적으로 아무 것도 하지 않음
         }
     }
     
     // 첫 실행 시 Healthkit 권한 설정이 되도록 호출합니다.
    mutating func setup() {
        service.configure()
        authorizationStatus = service.healthStore.authorizationStatus(for: sleepAnalysisType) // 여기서 healthStore에 접근하여 authorizationStatus를 확인합니다.
    }
}

