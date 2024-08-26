import SwiftUI

struct AccountDeletionView: View {
    @State private var isAgreed = false
    @State private var showConfirmationAlert = false
    @State private var showAgreementAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeletionResultAlert = false
    @State private var deletionSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            // 상단 Back 버튼 및 타이틀
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.leading, 16)

            Text("탈퇴하기")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)

            Spacer().frame(height: 20)

            // 탈퇴 안내 문구
            Text("탈퇴 전에 아래 내용을 꼭 확인해주세요.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                Text("1. 지금 탈퇴하시면 더 이상 해당 아이디로 로그인 할 수 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)

                Text("2. 계정 삭제 요청 후 계정과 모든 정보가 영구적으로 삭제되어 정보를 가져올 수 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 동의 체크박스
            HStack {
                Button(action: {
                    isAgreed.toggle()
                }) {
                    Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isAgreed ? .red : .gray)
                }
                Text("위 내용을 모두 확인하였으며, 이에 동의합니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)

            Spacer()

            // 취소 및 탈퇴하기 버튼
            HStack(spacing: 16) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("취소")
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    if isAgreed {
                        showConfirmationAlert = true
                    } else {
                        showAgreementAlert = true
                    }
                }) {
                    Text("탈퇴하기")
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isAgreed ? Color.red : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(title: Text("계정 탈퇴"),
                          message: Text("정말로 계정을 탈퇴하시겠습니까?"),
                          primaryButton: .destructive(Text("탈퇴하기")) {
                              deleteAccount()
                          },
                          secondaryButton: .cancel(Text("취소")))
                }
                .alert(isPresented: $showAgreementAlert) {
                    Alert(title: Text("동의 필요"), message: Text("위 내용을 확인하시고, 동의해주십시오."), dismissButton: .default(Text("확인")))
                }
                .alert(isPresented: $showDeletionResultAlert) {
                    Alert(title: deletionSuccess ? Text("탈퇴 성공") : Text("탈퇴 실패"),
                          message: deletionSuccess ? Text("성공적으로 계정이 삭제되었습니다.") : Text("탈퇴에 실패했습니다. 다시 시도해주세요."),
                          dismissButton: .default(Text("확인")) {
                              if deletionSuccess {
                                  presentationMode.wrappedValue.dismiss()
                              }
                          })
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            Spacer(minLength: 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }

    func deleteAccount() {
        guard let url = URL(string: "https://www.raem.shop/api/user/drawout") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // 저장된 accessToken을 헤더에 추가
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Account deletion request failed: \(error.localizedDescription)")
                    deletionSuccess = false
                    showDeletionResultAlert = true
                }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("No data received or invalid response")
                    deletionSuccess = false
                    showDeletionResultAlert = true
                }
                return
            }

            if httpResponse.statusCode == 200 {
                // 성공적인 응답 처리
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let isSuccess = json["isSuccess"] as? Bool, isSuccess {
                        DispatchQueue.main.async {
                            deletionSuccess = true
                            showDeletionResultAlert = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            deletionSuccess = false
                            showDeletionResultAlert = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                        deletionSuccess = false
                        showDeletionResultAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("Failed with HTTP status code: \(httpResponse.statusCode)")
                    deletionSuccess = false
                    showDeletionResultAlert = true
                }
            }
        }
        task.resume()
    }
}

struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}
