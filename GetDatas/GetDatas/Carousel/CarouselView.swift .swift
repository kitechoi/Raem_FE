import SwiftUI

struct CarouselView: View {
    @State private var currentIndex = 0
    @State private var showLoginView = false
    @State private var showRegisterView = false
    @Binding var isLoggedIn: Bool // LoadingView에서 전달받는 바인딩 상태

    
    let pages: [CarouselPage] = [
        CarouselPage(imageName: "page1", title: "편안한 수면", description: "숙면을 위한 완벽한 환경을 제공합니다."),
        CarouselPage(imageName: "page2", title: "스마트 수면 분석", description: "AI가 당신의 수면 패턴을 분석해 드립니다."),
        CarouselPage(imageName: "page3", title: "건강한 수면 관리", description: "당신의 수면 건강을 최우선으로 생각합니다.")
    ]
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    GeometryReader { geometry in
                        TabView(selection: $currentIndex) {
                            ForEach(pages.indices, id: \.self) { index in
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    Text(pages[index].title)
                                        .font(.system(size: 24, weight: .bold))
                                    
                                    Image(pages[index].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                    Text(pages[index].description)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 50)
                                
                               
                    
                                    
                                    // 마지막 슬라이드에 로그인과 회원가입 버튼 추가
                                    if index == pages.count - 1 {
                                        VStack(spacing: 16) {
                                            Button(action: {
                                                showLoginView = true
                                            }) {
                                                Text("로그인")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 50)
                                                    .background(Color.deepNavy)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                            
                                            Button(action: {
                                                showRegisterView = true
                                            }) {
                                                Text("회원가입")
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 50)
                                                    .background(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.deepNavy, lineWidth: 2)
                                                    )
                                                    .foregroundColor(.deepNavy)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 80)
                                    }else{
                                        Spacer()
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // 페이지네이션 추가
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { pageIndex in
                            Circle()
                                .fill(pageIndex == currentIndex ? Color.deepNavy : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 80)
                }
                WatchButton()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(destination: LoginView(), isActive: $showLoginView) {
                        EmptyView()
                }
            )
            .background(
                NavigationLink(destination: RegisterView(), isActive: $showRegisterView) {
                    EmptyView()
                }
            )
        }
    }
}

struct CarouselPage {
    let imageName: String
    let title: String
    let description: String
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(isLoggedIn: .constant(false))
    }
}
