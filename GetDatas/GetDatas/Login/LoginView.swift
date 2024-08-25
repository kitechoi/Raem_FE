import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var showRegisterView = false
    @State private var showAlert = false
    @State private var showMainView = false

    // SessionManager를 EnvironmentObject로 사용
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("raem")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color.deepNavy)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("이메일 입력")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                TextField("이메일 입력", text: $email)
                    .foregroundColor(.black)
                    .frame(height: 50)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호 입력")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack {
                    if isPasswordVisible {
                        TextField("비밀번호 입력", text: $password)
                            .foregroundColor(.black)
                            .frame(height: 50)
                            .padding(.horizontal, 15)
                    } else {
                        SecureField("비밀번호 입력", text: $password)
                            .foregroundColor(.black)
                            .frame(height: 50)
                            .padding(.horizontal, 15)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 15)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                
                if showErrorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }

            HStack {
                Spacer()
                Button(action: {
                    // 비밀번호 찾기 액션 추가
                }) {
                    Text("비밀번호 찾기")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }

            Button(action: {
                loginUser()
            }) {
                Text("로그인")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(email.isEmpty || password.isEmpty ? Color.gray : Color.deepNavy)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(email.isEmpty || password.isEmpty)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("로그인 실패"), message: Text(errorMessage), dismissButton: .default(Text("확인")))
            }
            .background(
                NavigationLink(destination: MainContentView(), isActive: $showMainView) {
                    EmptyView()
                }
            )

            HStack {
                Text("회원이 아니신가요?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Button(action: {
                    showRegisterView = true
                }) {
                    Text("회원가입 하러가기")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mint)
                }
                .background(
                    NavigationLink(destination: RegisterView(), isActive: $showRegisterView) {
                        EmptyView()
                    }
                )
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(24)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(leading: BackButton())
        .navigationBarBackButtonHidden(true)
    }
    
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            showErrorMessage = true
            return
        }

        let url = URL(string: "https://www.raem.shop/api/auth/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "서버와 연결할 수 없습니다: \(error.localizedDescription)"
                    showErrorMessage = true
                    showAlert = true
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    errorMessage = "서버에서 올바른 응답을 받지 못했습니다."
                    showErrorMessage = true
                    showAlert = true
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataDict = responseData["data"] as? [String: Any],
                   let accessToken = dataDict["accessToken"] as? String {
                    DispatchQueue.main.async {
                        // SessionManager를 사용하여 accessToken 저장
                        sessionManager.saveAccessToken(token: accessToken)
                        showMainView = true // MainView로 이동
                    }
                }
            } else {
                if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = responseData["message"] as? String {
                    DispatchQueue.main.async {
                        errorMessage = message
                        showErrorMessage = true
                        showAlert = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요."
                        showErrorMessage = true
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager())
    }
}
