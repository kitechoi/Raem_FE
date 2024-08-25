import SwiftUI

struct BottomNav: View {
    @Binding var selectedTab: Tab

    enum Tab: String {
        case home
        case sleep
        case sounds
        case settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.5))
            HStack(spacing: 0) {
                tabButton(for: .home, label: "Home", systemIconName: "house")
                tabButton(for: .sleep, label: "Sleep", systemIconName: "bed.double")
                tabButton(for: .sounds, label: "Sounds", systemIconName: "speaker.3")
                tabButton(for: .settings, label: "Settings", systemIconName: "gear")
            }
            .frame(maxWidth: .infinity) // 가로로 꽉 차도록 설정
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.bottom, 10)
        }
    }
    
    private func tabButton(for tab: Tab, label: String, systemIconName: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack {
                Image(systemName: systemIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedTab == tab ? Color.mint : Color.gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? Color.mint : Color.gray)
            }
            .frame(maxWidth: .infinity) // 각 버튼이 동일한 너비를 가집니다.
        }
    }
}
