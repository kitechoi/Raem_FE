import SwiftUI

@main
struct GetDatasApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var bleManager = BLEManager()

    var body: some Scene {
        WindowGroup {
            LoadingView()
                .environmentObject(sessionManager)
                .environmentObject(bleManager)
        }
    }
}


// 로그인 세션 관리 클래스
class SessionManager: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var username: String = "잠만보"
    @Published var email: String = "jammanbo@duksung.com"
    @Published var isLoading: Bool = false

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
            self.isLoading = true
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Failed to fetch user data: \(error.localizedDescription)")
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                    self.isLoading = false
                }
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(UserDataResponse.self, from: data)
                DispatchQueue.main.async {
                    if jsonResponse.isSuccess {
                        self.username = jsonResponse.data.username
                        self.email = jsonResponse.data.email
                    } else {
                        print("Failed to fetch user data: \(jsonResponse.message)")
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }

    // 탈퇴 함수 추가
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let token = accessToken else {
            completion(false, "AccessToken이 없습니다.")
            return
        }

        guard let url = URL(string: "https://www.raem.shop/api/user/drawout") else {
            completion(false, "잘못된 URL입니다.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "탈퇴 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(false, "잘못된 응답입니다.")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let jsonResponse = try JSONDecoder().decode(AccountDeletionResponse.self, from: data)

                    if jsonResponse.isSuccess {
                        DispatchQueue.main.async {
                            self.logout() // 로그아웃 처리
                            completion(true, nil)  // 탈퇴 성공
                        }
                    } else {
                        completion(false, jsonResponse.message)
                    }
                } catch {
                    completion(false, "응답 파싱 실패: \(error.localizedDescription)")
                }
            } else {
                completion(false, "HTTP 오류 코드: \(httpResponse.statusCode)")
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

struct AccountDeletionResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}
