import SwiftUI

struct SleepView: View {
    @State private var selectedTab: Tab = .today
    @State private var selectedTabLabel: String = "오늘"
    
    enum Tab {
        case today
        case weekly
        case monthly
        case annually
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("수면 분석")
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.black)
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Spacer()
                    tabButton(for: .today, label: "오늘")
                    Divider()
                        .frame(width: 1, height: 17)
                        .background(.black)
                    tabButton(for: .weekly, label: "1주")
                    Divider()
                        .frame(width: 1, height: 17)
                        .background(.black)
                    tabButton(for: .monthly, label: "1달")
                    Divider()
                        .frame(width: 1, height: 17)
                        .background(.black)
                    tabButton(for: .annually, label: "1년")
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 44)
                )
                
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color.deepNavy)  // 선택된 탭의 배경 색상
                        .frame(width: (geometry.size.width / 4) + 4, height: 44)
                        .offset(x: self.getOffset(for: selectedTab, in: geometry.size.width))
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }

                GeometryReader { geometry in
                    Text(selectedTabLabel)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width / 4, height: 44)
                        .offset(x: self.getOffset(for: selectedTab, in: geometry.size.width))
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
            }
            .frame(height: 44)
            
            ScrollView {
                switch selectedTab {
                case .today:
                    DailyView()
                case .weekly:
                    WeeklyView()
                case .monthly:
                    MonthlyView()
                case .annually:
                    AnnuallyView()
                }
            }
            
            Spacer()
        }
        .padding(.top, 70)
        .padding(.horizontal, 16)
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
    }
    
    private func getOffset(for tab: Tab, in totalWidth: CGFloat) -> CGFloat {
        let numberOfTabs = 4
        let tabWidth = totalWidth / CGFloat(numberOfTabs)
        switch tab {
        case .today:
            return 0
        case .weekly:
            return tabWidth - 2
        case .monthly:
            return (tabWidth * 2) - 2
        case .annually:
            return (tabWidth * 3) - 2
        }
    }
    
    private func tabButton(for tab: Tab, label: String) -> some View {
        Button(action: {
            selectedTab = tab
            selectedTabLabel = label
        }) {
            VStack {
                Text(label)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        SleepView()
    }
}
