import SwiftUI

@main
struct GetDatasApp: App {
    @StateObject private var sessionManager = SessionManager()
    @ObservedObject var bleManager = BLEManager()

    var body: some Scene {
        WindowGroup {
            LoadingView()
                .environmentObject(sessionManager)
                .environmentObject(bleManager)
//            MlTestView() // 연_test예측화면
        }
    }
}

// 로그인 세션 관리 클래스
class SessionManager: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var username: String = "잠만보"  // 기본값으로 "잠만보" 설정
    @Published var email: String = "jammanbo@duksung.com"
    @Published var isLoading: Bool = false  // 로딩 상태 관리 변수 추가

    func saveAccessToken(token: String) {
        self.accessToken = token
        self.isLoggedIn = true
        UserDefaults.standard.set(token, forKey: "accessToken")
        fetchUserData()
    }

    func loadAccessToken() {
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            self.accessToken = token
            self.isLoggedIn = true
            fetchUserData()
        }
    }

    func logout() {
        self.accessToken = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }

    func fetchUserData() {
        guard let token = accessToken else {
            print("Access token is missing")
            return
        }

        guard let url = URL(string: "https://www.raem.shop/api/user/data") else {
            print("Invalid URL")
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true  // 데이터를 가져오기 전 로딩 상태로 설정
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Failed to fetch user data: \(error.localizedDescription)")
                    self.isLoading = false  // 실패 시 로딩 상태 해제
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                    self.isLoading = false  // 실패 시 로딩 상태 해제
                }
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(UserDataResponse.self, from: data)
                DispatchQueue.main.async {
                    if jsonResponse.isSuccess {
                        self.username = jsonResponse.data.username  // 서버에서 받은 이름으로 업데이트
                        self.email = jsonResponse.data.email
                    } else {
                        print("Failed to fetch user data: \(jsonResponse.message)")
                    }
                    self.isLoading = false  // 데이터 로딩 완료 후 로딩 상태 해제
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                    self.isLoading = false  // 실패 시 로딩 상태 해제
                }
            }
        }
        task.resume()
    }
}


struct UserDataResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let data: UserData
}

struct UserData: Codable {
    let username: String
    let email: String
    let imageUrl: String?
    let created_at: String
}
