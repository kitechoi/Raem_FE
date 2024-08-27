import SwiftUI

struct EmailChangeView: View {
    @Binding var currentEmail: String
    @State private var emailAddress: String = ""
    @Environment(\.presentationMode) var presentationMode // 이전 화면으로 돌아가기 위해 사용

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "이메일 변경")
            Spacer()
                .frame(height: 40) // 충분한 여백 추가
            
            // 이메일 입력 필드
            VStack(alignment: .leading) {
                Text("이메일 주소")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("이메일 주소 입력", text: $emailAddress)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray)
                            , alignment: .bottom
                        )
                    
                    // "X" 버튼
                    if !emailAddress.isEmpty {
                        Button(action: {
                            emailAddress = "" // 입력된 텍스트를 지움
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !emailAddress.isEmpty {
                    Text("example@email.com")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
                .frame(height: 20)
            
            // 인증 메일 보내기 버튼
            Button(action: {
                currentEmail = emailAddress // 변경된 이메일을 반영
                presentationMode.wrappedValue.dismiss() // AccountManagementView로 돌아감
            }) {
                Text("인증 메일 보내기")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(emailAddress.isEmpty ? Color.gray.opacity(0.2) : Color.blue) // 텍스트 입력 시 파란색
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .disabled(emailAddress.isEmpty) // 텍스트가 없으면 버튼 비활성화
            
            Spacer() // 하단 여백 추가
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct EmailChangeView_Previews: PreviewProvider {
    static var previews: some View {
        EmailChangeView(currentEmail: .constant("zammanbo111@duksung.ac.kr"))
    }
}

