import SwiftUI

struct PasswordChangeView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @Binding var savedPassword: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "비밀번호 변경")
            Spacer()
                .frame(height: 40)
            
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
                                .foregroundColor(Color.gray)
                            , alignment: .bottom
                        )
                    
                    // "X" 버튼
                    if !currentPassword.isEmpty {
                        Button(action: {
                            currentPassword = "" // 입력된 텍스트를 지움
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
            
            Spacer()
                .frame(height: 20)
            
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
                                .foregroundColor(Color.gray)
                            , alignment: .bottom
                        )
                    
                    // "X" 버튼
                    if !newPassword.isEmpty {
                        Button(action: {
                            newPassword = "" // 입력된 텍스트를 지움
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
            
            Spacer()
                .frame(height: 20)
            
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
                                .foregroundColor(Color.gray)
                            , alignment: .bottom
                        )
                    
                    // "X" 버튼
                    if !confirmPassword.isEmpty {
                        Button(action: {
                            confirmPassword = "" // 입력된 텍스트를 지움
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
            
            Spacer()
                .frame(height: 20)
            
            // 변경 버튼
            Button(action: {
                if newPassword == confirmPassword {
                    savedPassword = newPassword // 변경된 비밀번호를 반영
                    presentationMode.wrappedValue.dismiss() // AccountManagementView로 돌아감
                } else {
                    // 비밀번호가 일치하지 않는 경우 처리
                    // 알림을 띄우는 로직 추가 가능
                }
            }) {
                Text("변경")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((newPassword.isEmpty || confirmPassword.isEmpty) ? Color.gray.opacity(0.2) : Color.blue) // 텍스트 입력 시 파란색
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .disabled(newPassword.isEmpty || confirmPassword.isEmpty) // 텍스트가 없으면 버튼 비활성화
            
            Spacer() // 하단 여백 추가
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct PasswordChangeView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordChangeView(savedPassword: .constant("********"))
    }
}

