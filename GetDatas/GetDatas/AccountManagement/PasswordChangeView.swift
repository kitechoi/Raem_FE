import SwiftUI

struct PasswordChangeView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "비밀번호 변경")
            Spacer().frame(height: 40)
            
            // 현재 비밀번호 입력 필드
            VStack(alignment: .leading) {
                Text("현재 비밀번호")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    SecureField("현재 비밀번호 입력", text: $currentPassword)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray),
                            alignment: .bottom
                        )
                    
                    if !currentPassword.isEmpty {
                        Button(action: {
                            currentPassword = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !currentPassword.isEmpty {
                    Text("8~20자리 문자 (영문, 숫자, 특수문자 사용 가능)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 20)
            
            // 새 비밀번호 입력 필드
            VStack(alignment: .leading) {
                Text("새 비밀번호")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    SecureField("새 비밀번호 입력", text: $newPassword)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray),
                            alignment: .bottom
                        )
                    
                    if !newPassword.isEmpty {
                        Button(action: {
                            newPassword = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !newPassword.isEmpty {
                    Text("8~20자리 문자 (영문, 숫자, 특수문자 사용 가능)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 20)
            
            // 새 비밀번호 확인 입력 필드
            VStack(alignment: .leading) {
                Text("새 비밀번호 확인")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    SecureField("새 비밀번호 다시 입력", text: $confirmPassword)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray),
                            alignment: .bottom
                        )
                    
                    if !confirmPassword.isEmpty {
                        Button(action: {
                            confirmPassword = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !confirmPassword.isEmpty {
                    Text("8~20자리 문자 (영문, 숫자, 특수문자 사용 가능)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 20)
            
            // 변경 버튼
            Button(action: {
                if newPassword == confirmPassword {
                    changePassword() // 비밀번호 변경 API 호출
                } else {
                    alertMessage = "새 비밀번호가 일치하지 않습니다."
                    showAlert = true
                }
            }) {
                Text("변경")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((newPassword.isEmpty || confirmPassword.isEmpty) ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .disabled(newPassword.isEmpty || confirmPassword.isEmpty)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    // 비밀번호 변경 API 호출
    func changePassword() {
        guard let accessToken = sessionManager.accessToken else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }

        let url = URL(string: "https://www.raem.shop/api/user?target=pw")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let parameters: [String: Any] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "서버 오류: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            if let data = data, let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let isSuccess = response["isSuccess"] as? Bool, let message = response["message"] as? String {
                DispatchQueue.main.async {
                    if isSuccess {
                        alertMessage = "비밀번호가 성공적으로 변경되었습니다."
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        alertMessage = message
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}

