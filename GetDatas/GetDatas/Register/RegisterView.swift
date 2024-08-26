import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isRegistered = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = false

    var isFormValid: Bool {
        return !username.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }

    var body: some View {
        ZStack {
            Color.white // 배경 색상을 흰색으로 설정
                .edgesIgnoringSafeArea(.all) // 모든 안전 영역을 무시하고 배경을 채웁니다.

            VStack {
                Spacer()

                // 제목 텍스트
                Text(attributedTitle)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)

                // 닉네임 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    TextField("사용하실 닉네임 입력", text: $username)
                        .frame(height: 50)
                        .padding(.horizontal)
                        .foregroundColor(.black) // 입력한 글자 색상
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .placeholder(when: username.isEmpty) {
                            Text("사용하실 닉네임 입력").foregroundColor(.gray).padding(.horizontal)
                        }
                }.padding(.bottom, 20)

                // 이메일 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    TextField("이메일 주소 입력", text: $email, onEditingChanged: { isEditing in
                        if !isEditing {
                            isEmailValid = isValidEmail(email)
                        }
                    })
                    .onChange(of: email) { newValue in
                        email = filterInvalidCharacters(from: newValue)
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                    .foregroundColor(.black) // 입력한 글자 색상
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .placeholder(when: email.isEmpty) {
                        Text("이메일 주소 입력").foregroundColor(.gray).padding(.horizontal)
                    }
                    
                    Text("이메일 형식이 잘못되었습니다.")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .opacity(isEmailValid ? 0 : 1)
                }
                .padding(.bottom, 0)

                // 비밀번호 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("비밀번호 입력", text: $password, onCommit: {
                        isPasswordValid = isValidPassword(password)
                    })
                    .onChange(of: password) { newValue in
                        password = filterInvalidCharacters(from: newValue)
                        isPasswordValid = isValidPassword(password)
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                    .foregroundColor(.black) // 입력한 글자 색상
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .placeholder(when: password.isEmpty) {
                        Text("비밀번호 입력").foregroundColor(.gray).padding(.horizontal)
                    }
                    
                    Text("영어와 숫자, 특수문자가 모두 포함되어 있어야 합니다.")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .opacity(isPasswordValid ? 0 : 1)
                }
                .padding(.bottom, 0)
                
                // 비밀번호 확인 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("비밀번호 확인", text: $confirmPassword)
                        .onChange(of: confirmPassword) { newValue in
                            confirmPassword = filterInvalidCharacters(from: newValue)
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        .foregroundColor(.black) // 입력한 글자 색상
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .placeholder(when: confirmPassword.isEmpty) {
                            Text("비밀번호 확인").foregroundColor(.gray).padding(.horizontal)
                        }
                }
                

                // 회원가입 버튼
                Button(action: {
                    if !isFormValid {
                        alertMessage = "정보를 모두 입력해주세요."
                        showAlert = true
                    } else if password != confirmPassword {
                        alertMessage = "비밀번호가 일치하지 않습니다. 다시 확인해주세요."
                        showAlert = true
                    } else {
                        registerUser()
                    }
                }) {
                    Text("회원가입")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.deepNavy : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(!isFormValid)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                }
                .background(
                    NavigationLink(destination: RegisterCompleteView(), isActive: $isRegistered) {
                        EmptyView()
                    }
                )
                .padding(.top, 20)

                Spacer()
            }
            .padding(24)
        }
        .navigationBarItems(leading: BackButton()) // 커스텀 백 버튼 추가
        .navigationBarBackButtonHidden(true)
    }

    private var attributedTitle: AttributedString {
        var attributedString = AttributedString("raem 가입을 환영합니다.")
        if let range = attributedString.range(of: "raem") {
            attributedString[range].foregroundColor = Color.deepNavy
        }
        if let range = attributedString.range(of: "가입을 환영합니다.") {
            attributedString[range].foregroundColor = Color.black
        }
        return attributedString
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }

    // 한글을 제외한 문자만 허용하는 필터 함수
    private func filterInvalidCharacters(from input: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;':,.<>?/~`")
        return input.filter { allowedCharacters.contains($0.unicodeScalars.first!) }
    }

    private func registerUser() {
        guard let url = URL(string: "https://www.raem.shop/api/auth/signup") else {
            alertMessage = "잘못된 URL입니다."
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["username": username, "email": email, "password": password]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "회원가입 중 오류가 발생했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard data != nil else {
                DispatchQueue.main.async {
                    alertMessage = "서버에서 응답이 없습니다."
                    showAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // 회원가입 성공 처리
                DispatchQueue.main.async {
                    isRegistered = true
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "회원가입에 실패했습니다."
                    showAlert = true
                }
            }
        }.resume()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
