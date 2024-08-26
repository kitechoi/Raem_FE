import SwiftUI

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    var placeholder: String
    var isSecure: Bool
    @Binding var isPasswordVisible: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.backgroundColor = UIColor.white
        textField.isSecureTextEntry = isSecure && !isPasswordVisible

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecure && !isPasswordVisible
    }
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var showRegisterView = false
    @State private var showAlert = false
    @State private var showMainView = false

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
                
                CustomTextField(text: $email, placeholder: "이메일 입력", isSecure: false, isPasswordVisible: $isPasswordVisible)
                    .foregroundColor(.black)
                    .frame(height: 50)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호 입력")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack {
                    CustomTextField(text: $password, placeholder: "비밀번호 입력", isSecure: true, isPasswordVisible: $isPasswordVisible)
                        .foregroundColor(.black)
                        .frame(height: 50)
                        .padding(.horizontal, 15)

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
                    .background(isLoginButtonEnabled() ? Color.deepNavy : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(!isLoginButtonEnabled())
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
    
    private func isLoginButtonEnabled() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }

    private func loginUser() {
        guard isValidEmail(email) else {
            errorMessage = "이메일 형식에 맞게 입력해주세요."
            showErrorMessage = true
            showAlert = true
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
                        sessionManager.saveAccessToken(token: accessToken)
                        showMainView = true
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

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager())
    }
}
