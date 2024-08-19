import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 60) {  // 각 버튼 사이 간격 조정
                TabBarButton(imageName: selectedTab == .home ? "home_mint" : "home_gray", tab: .home, selectedTab: $selectedTab)

                TabBarButton(imageName: selectedTab == .sleep ? "sleep_mint" : "sleep_gray", tab: .sleep, selectedTab: $selectedTab)

                TabBarButton(imageName: selectedTab == .sounds ? "sounds_mint" : "sounds_gray", tab: .sounds, selectedTab: $selectedTab)

                TabBarButton(imageName: selectedTab == .settings ? "settings_mint" : "settings_gray", tab: .settings, selectedTab: $selectedTab)
            }
            .padding(.vertical, 10)  // 위아래 간격 조정
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.95)]), startPoint: .top, endPoint: .bottom)  // 매우 약한 그라데이션 효과
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

enum Tab: String {
    case home = "Home"
    case sleep = "Sleep"
    case sounds = "Sounds"
    case settings = "Settings"
}

struct TabBarButton: View {
    let imageName: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 2) {  // 이미지와 텍스트 사이 간격 조정
                Image(imageName)
                    .resizable()
                    .frame(width: 24, height: 24)  // 이미지 크기 조정
                Text(tab.rawValue)
                    .font(.system(size: 12))  // 텍스트 크기 조정
                    .foregroundColor(selectedTab == tab ? Color.mint : Color.gray)
            }
        }
    }
}

