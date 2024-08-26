import SwiftUI

struct AccountManagementView: View {
    @State private var selectedImage: UIImage? = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지
    @State private var isImagePickerPresented = false
    @State private var showNameChangeView = false
    @State private var showEmailChangeView = false // 이메일 변경 뷰로 이동하기 위한 상태
    @State private var showPasswordChangeView = false // 비밀번호 변경 뷰로 이동하기 위한 상태
    @State private var currentName: String = ""  // API에서 불러온 이름 상태
    @State private var currentEmail: String = ""  // API에서 불러온 이메일 상태
    @State private var savedPassword: String = "********" // 현재 비밀번호 상태 (일반적으로 비밀번호는 서버에서 가져오지 않음)
    @State private var showAccountDeletionView = false  // 탈퇴 페이지로 이동하기 위한 상태
    @State private var apiResponse: String = "" // API로부터 받은 전체 응답을 문자열로 저장
    @State private var accessToken: String = "" // accessToken을 저장하기 위한 상태 변수

    @State private var isLoggedOut = false  // 로그아웃 상태를 관리하는 변수
    @State private var showLogoutAlert = false  // 로그아웃 후 알림 표시 여부
    @State private var logoutSuccess = false  // 로그아웃 성공 여부
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "계정 관리")
            Spacer()
            
            // 프로필 이미지 및 변경 버튼
            VStack {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    ZStack {
                        Image(uiImage: selectedImage ?? UIImage(systemName: "person.crop.circle.fill")!)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        // 사진 변경 아이콘
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.mint)
                            .background(Circle().fill(Color.white))
                            .offset(x: 35, y: 35)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            
            Spacer()
                .frame(height: 20)
            
            // 이름, 이메일, 비밀번호 변경 섹션
            VStack(spacing: 16) {
                HStack {
                    Text("이름")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(currentName)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showNameChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: NameChangeView(currentName: $currentName), isActive: $showNameChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
                
                HStack {
                    Text("이메일")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(currentEmail) // 변경된 이메일이 반영됨
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showEmailChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: EmailChangeView(currentEmail: $currentEmail), isActive: $showEmailChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
                
                HStack {
                    Text("비밀번호")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(savedPassword) // 현재 저장된 비밀번호 표시
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showPasswordChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: PasswordChangeView(savedPassword: $savedPassword), isActive: $showPasswordChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
            }
            .padding(.horizontal, 16)
            
            Spacer()

            // AccessToken 출력
            Text("AccessToken:")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 20)
            
            ScrollView {
                Text(accessToken)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
            }
            .frame(height: 80)

            // API 응답 전체를 문자열로 표시
            Text("API Response:")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 20)
            
            ScrollView {
                Text(apiResponse)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
            }
            .frame(height: 150)

            Spacer()
            
            // 로그아웃 및 탈퇴하기 버튼
            HStack {
                Button(action: {
                    logout()
                }) {
                    Text("로그아웃")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
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
                    // 로그아웃 후 이동할 뷰 지정
                    LoadingView()
                }
                
                Spacer()
                
                Button(action: {
                    showAccountDeletionView = true  // 탈퇴 페이지로 이동
                }) {
                    Text("탈퇴하기")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .background(
                    NavigationLink(destination: AccountDeletionView(), isActive: $showAccountDeletionView) {
                        EmptyView()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadAccessToken()
            fetchUserData()
        }
    }
    
    func loadAccessToken() {
        // UserDefaults에서 accessToken을 불러오고, UI에 표시합니다.
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            self.accessToken = token
        } else {
            self.accessToken = "AccessToken not found"
        }
    }

    func fetchUserData() {
        guard !accessToken.isEmpty else {
            print("Access token is missing")
            return
        }
        
        guard let url = URL(string: "https://www.raem.shop/api/user/data") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(UserDataResponse.self, from: data)
                if jsonResponse.isSuccess {
                    DispatchQueue.main.async {
                        self.currentName = jsonResponse.data.username
                        self.currentEmail = jsonResponse.data.email
                        if let urlString = jsonResponse.data.imageUrl,
                           let url = URL(string: "https://www.raem.shop/images/\(urlString)"),
                           let imageData = try? Data(contentsOf: url),
                           let image = UIImage(data: imageData) {
                            self.selectedImage = image
                        }
                        self.apiResponse = String(data: data, encoding: .utf8) ?? "Invalid JSON format"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.apiResponse = String(data: data, encoding: .utf8) ?? "Invalid JSON format"
                    }
                    print("Failed to fetch user data: \(jsonResponse.message)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.apiResponse = "Failed to decode JSON: \(error.localizedDescription)"
                }
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func logout() {
        guard let url = URL(string: "https://www.raem.shop/api/user/logout") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 저장된 accessToken을 헤더에 추가
        guard !accessToken.isEmpty else {
            print("Access token is missing")
            return
        }
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
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

struct AccountManagementView_Previews: PreviewProvider {
    static var previews: some View {
        AccountManagementView()
            .environmentObject(SessionManager())
    }
}
