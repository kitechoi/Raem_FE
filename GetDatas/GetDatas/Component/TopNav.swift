import SwiftUI

struct TopNav: View {
    @Binding var navigateToLoadingView: Bool  // LoadingView로 이동하기 위한 상태
    @Binding var navigateToMyPage: Bool  // AccountManagementView로 이동하기 위한 상태

    var body: some View {
        HStack {
            Button(action: {
                navigateToLoadingView = true
            }) {
                Text("raem")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.deepNavy)
            }
            
            Spacer()
            
            Button(action: {
                navigateToMyPage = true
            }) {
                Image("mypage")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
        }
        .padding(.horizontal, 23)
        .padding(.top, 60)
    }
}

struct TopNav_Previews: PreviewProvider {
    @State static var navigateToLoadingView = false
    @State static var navigateToMyPage = false

    static var previews: some View {
        TopNav(navigateToLoadingView: $navigateToLoadingView, navigateToMyPage: $navigateToMyPage)
            .edgesIgnoringSafeArea(.top)
            .environmentObject(SessionManager())
    }
}
