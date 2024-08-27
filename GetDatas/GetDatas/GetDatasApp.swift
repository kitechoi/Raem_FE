import SwiftUI

@main
struct GetDatasApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            LoadingView()
                .environmentObject(sessionManager)
//            MlTestView() // 연_test예측화면
//            SleepStageView()
        }
    }
}



// 로그인 세션 관리 클래스

class SessionManager: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var isLoggedIn: Bool = false
    
    func saveAccessToken(token: String) {
        self.accessToken = token
        self.isLoggedIn = true
        // 토큰을 UserDefaults에 저장하여 앱 재시작 시에도 유지
        UserDefaults.standard.set(token, forKey: "accessToken")
    }
    
    func loadAccessToken() {
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            self.accessToken = token
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        self.accessToken = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
}
