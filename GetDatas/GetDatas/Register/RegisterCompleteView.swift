import SwiftUI

struct RegisterCompleteView: View {
    @State private var showDeviceRegistration = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // 체크 이미지
            Image("complete")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            // 완료 메시지
            Text("회원 가입 완료!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text("회원가입이 성공적으로 완료되었습니다.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // 기기 등록하기 버튼
            Button(action: {
                showDeviceRegistration = true
            }) {
                Text("기기 등록하기")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.deepNavy)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .background(
                NavigationLink(destination: DeviceRegistrationView(), isActive: $showDeviceRegistration) {
                    EmptyView()
                }
            )

            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct RegisterCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterCompleteView()
    }
}

