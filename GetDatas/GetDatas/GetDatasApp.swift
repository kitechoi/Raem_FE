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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }

    init() {
        setup()
    }

    // 첫 실행 시 Healthkit 권한 설정이 되도록 호출합니다.
    mutating func setup() {
        service.configure()
        authorizationStatus = service.healthStore.authorizationStatus(for: sleepAnalysisType)

        // 권한이 아직 요청되지 않은 경우 권한을 요청합니다.
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        }
    }

    // 권한 요청 메소드
    mutating func requestAuthorization() {
        service.healthStore.requestAuthorization(toShare: service.share, read: service.read) { success, error in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
                return
            }

            if success {
                print("권한이 허락되었습니다")
            } else {
                print("권한이 없습니다")
            }
        }
    }
}
