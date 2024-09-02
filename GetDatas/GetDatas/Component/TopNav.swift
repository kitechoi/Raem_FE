import SwiftUI

struct TopNav: View {
    @State private var navigateToLoadingView = false
    @State private var navigateToMyPage = false

    var body: some View {
        HStack {
            NavigationLink(destination: LoadingView(), isActive: $navigateToLoadingView) {
                Button(action: {
                    navigateToLoadingView = true
                }) {
                    Text("raem")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.deepNavy)
                }
            }

            Spacer()

            NavigationLink(destination: AccountManagementView(), isActive: $navigateToMyPage) {
                Button(action: {
                    navigateToMyPage = true
                }) {
                    Image("mypage")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }
        }
        .padding(.horizontal, 23)
        .padding(.top, 60)
    }
}

struct TopNav_Previews: PreviewProvider {
    static var previews: some View {
        TopNav()
            .edgesIgnoringSafeArea(.top)
            .environmentObject(SessionManager())  // SessionManager를 미리보기에서 제공
    }
}
