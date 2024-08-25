import SwiftUI

struct TopNav: View {
    @State private var isLoggedOut = false  // 로그아웃 상태를 관리하는 변수
    @State private var showLogoutAlert = false  // 로그아웃 후 알림 표시 여부
    @State private var logoutSuccess = false  // 로그아웃 성공 여부
    @State private var navigateToLoadingView = false  // LoadingView로 이동하기 위한 상태

    var body: some View {
            HStack {
                Button(action: {
                    navigateToLoadingView = true
                }) {
                    Text("raem")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.deepNavy)
                }
                
                Spacer()
                
                Button(action: {
                    logout()
                }) {
                    Image("mypage")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }
            .padding(.horizontal, 23)
            .padding(.top, 60)  // 화면 높이에 비례하여 상단 패딩 조정
            .alert(isPresented: $showLogoutAlert) {
                if logoutSuccess {
                    return Alert(
                        title: Text("로그아웃 성공"),
                        message: Text("성공적으로 로그아웃되었습니다."),
                        dismissButton: .default(Text("확인")) {
                            isLoggedOut = true
                        }
                    )
                } else {
                    return Alert(
                        title: Text("로그아웃 실패"),
                        message: Text("로그아웃에 실패했습니다. 다시 시도해주세요."),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoadingView()
            }
            .background(
                NavigationLink(destination: LoadingView(), isActive: $navigateToLoadingView) {
                    EmptyView()
                }
            )
        }
    
    func logout() {
        guard let url = URL(string: "https://www.raem.shop/api/user/logout") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 저장된 accessToken을 헤더에 추가
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // 필요 시 추가 헤더 설정
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Logout request failed: \(error.localizedDescription)")
                    logoutSuccess = false
                    showLogoutAlert = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("Logout failed with unexpected response")
                    logoutSuccess = false
                    showLogoutAlert = true
                }
                return
            }

            DispatchQueue.main.async {
                // 로그아웃 성공 후 상태 변경 및 accessToken 삭제
                UserDefaults.standard.removeObject(forKey: "accessToken")
                logoutSuccess = true
                showLogoutAlert = true
            }
        }
        task.resume()
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopNav()
            .edgesIgnoringSafeArea(.top)
    }
}

