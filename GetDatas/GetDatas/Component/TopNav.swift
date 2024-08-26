import SwiftUI

struct TopNav: View {
    @State private var navigateToLoadingView = false  // LoadingView로 이동하기 위한 상태
    @State private var navigateToMyPage = false  // AccountManagementView로 이동하기 위한 상태

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
        .padding(.top, 60)  // 화면 높이에 비례하여 상단 패딩 조정
        .fullScreenCover(isPresented: $navigateToLoadingView) {
            LoadingView()
        }
        .fullScreenCover(isPresented: $navigateToMyPage) {
            AccountManagementView()
        }
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopNav()
            .edgesIgnoringSafeArea(.top)
            .environmentObject(SessionManager())  // SessionManager를 미리보기에서 제공
    }
}
