import SwiftUI

struct NameChangeView: View {
    @State private var newName: String = ""
    @Binding var currentName: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "닉네임 변경")
            Spacer().frame(height: 40)

            // 이름 입력 필드
            VStack(alignment: .leading) {
                Text("이름")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("사용하실 닉네임 입력", text: $newName)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray),
                            alignment: .bottom
                        )
                    
                    if !newName.isEmpty {
                        Button(action: {
                            newName = "" // 입력된 텍스트를 지움
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer().frame(height: 20)

            // 변경 버튼
            Button(action: {
                changeName() // 이름 변경 API 호출
            }) {
                Text("변경")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newName.isEmpty ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .disabled(newName.isEmpty)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }

            Spacer() // 하단 여백 추가
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }

    // 이름 변경 API 호출
    func changeName() {
        guard let accessToken = sessionManager.accessToken else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }

        let url = URL(string: "https://www.raem.shop/api/user?target=name")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let parameters: [String: Any] = [
            "username": newName,
            "currentPassword": NSNull(),
            "newPassword": NSNull(),
            "newEmail": NSNull(),
            "code": NSNull()
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
                        currentName = newName
                        alertMessage = "이름이 성공적으로 변경되었습니다."
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

struct NameChangeView_Previews: PreviewProvider {
    static var previews: some View {
        NameChangeView(currentName: .constant("잠만보"))
            .environmentObject(SessionManager())
    }
}

