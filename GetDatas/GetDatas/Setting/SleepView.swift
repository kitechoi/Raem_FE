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
                    .font(.system(size: 28, weight: .bold))
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
                        .fill(Color.home_mint)  // 선택된 탭의 배경 색상
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
                    DailySleepView()
                case .weekly:
                    WeeklySleepView()
                case .monthly:
                    MonthlySleepView()
                case .annually:
                    AnnuallySleepView()
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


struct DailySleepView: View {
    @State private var popUpVisible: Bool = false
    @State private var selectedReason: Reason? = nil
    @State private var rating: Int = 2
    @State private var sleptAt: String = "2024-08-31"
    @State private var sleepHour: String = "09"
    @State private var sleepMinute: String = "41"
    
    enum Reason {
        case caffeine
        case exercise
        case stress
        case alcohol
        case smartphone
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16){
                VStack(spacing: 20) {
                    HStack {
                        Text("수면 별점")
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                    }
                    
                    HStack(spacing: 10){
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(index <= rating ? .yellow : .gray)
                        }
                    }
                    
                    Text("오늘의 별점은 \(rating)점 입니다.")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                    
                    if rating <= 3 {
                        Button(action: {
                            popUpVisible = true
                        }) {
                            Text("더보기")
                                .font(.system(size: 17))
                                .foregroundColor(.home_mint)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("수면 깊이")
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                    }
                    
                    VStack(alignment: .leading){
                        HStack(alignment: .bottom) {
                            HStack(spacing: 12) {
                                Image("moon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                
                                Text("\(sleepHour)")
                                    .font(.system(size: 24, weight: .bold)) +
                                Text("시")
                                    .font(.system(size: 20, weight: .bold)) +
                                Text(" \(sleepMinute)")
                                    .font(.system(size: 24, weight: .bold)) +
                                Text("분")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            
                            Spacer()
                            Text("\(sleptAt)")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        
                        Text("어제보다 46분 더 주무셨네요.")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                            .padding(.bottom, 12)
                        
                        //그래프
                        
                        HStack{
                            Spacer()
                            VStack(alignment: .leading) {
                                HStack(spacing: 45) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 16) {
                                            Image("moon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            VStack(alignment: .leading, spacing: 4){
                                                Text("6시간 52분")
                                                    .font(Font.system(size: 18, weight: .bold))
                                                    .foregroundColor(.black)
                                                Text("Time in sleep")
                                                    .font(Font.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.trailing, 10)

                                    VStack(spacing: 4) {
                                        HStack(spacing: 16) {
                                            Image("zzz")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            VStack(alignment: .leading, spacing: 4){
                                                Text("25분")
                                                    .font(Font.system(size: 18, weight: .bold))
                                                    .foregroundColor(.black)
                                                Text("Fell asleep")
                                                    .font(Font.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 20)
                                
                                HStack(spacing: 45) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 16) {
                                            Image("watch")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            VStack(alignment: .leading, spacing:4) {
                                                Text("7시간 23분")
                                                    .font(Font.system(size: 18, weight: .bold))
                                                    .foregroundColor(.black)
                                                Text("Went to bed")
                                                    .font(Font.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.trailing, 10)

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 16) {
                                            Image("sun")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("07시 12분")
                                                    .font(Font.system(size: 18, weight: .bold))
                                                    .foregroundColor(.black)
                                                Text("Wake up time")
                                                    .font(Font.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 25)
                                .padding(.bottom, 18)
                            }
                            Spacer()
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            if popUpVisible {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                popUpVisible = false
                            }) {
                                Image("closeMark")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                            }
                        }
                        
                        Text("오늘 해당하는 사항이 있나요?")
                            .font(.system(size: 18, weight: .bold))
                        
                        Spacer()
                        
                        VStack {
                            VStack(alignment: .leading) {
                                tabReason(for: .caffeine, label: "카페인 음료")
                                tabReason(for: .exercise, label: "격렬한 운동")
                                tabReason(for: .stress, label: "과도한 스트레스")
                                tabReason(for: .alcohol, label: "음주")
                                tabReason(for: .smartphone, label: "자기 전 스마트폰 사용")
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                //나쁜 기상 이유 제출 함수
                                popUpVisible = false
                            }) {
                                Text("기록하기")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.deepNavy)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(width: 297, height: 297)
                    .background(Color.lightGray)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
                .transition(.opacity) // 페이드 인/아웃 효과
                .animation(.easeInOut, value: popUpVisible) // 애니메이션 효과
            }
        }
    }
    
    private func tabReason(for reason: Reason, label: String) -> some View {
        Button(action: {
            selectedReason = (selectedReason == reason) ? nil : reason
        }) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(selectedReason == reason ? Color.home_mint : Color.gray)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Color.gray)
        }
    }
}

struct WeeklySleepView: View {
    
    var body: some View {
        Text("Weekly Sleep View")
    }
}

struct MonthlySleepView: View {
    
    var body: some View {
        Text("Monthly Sleep View")
    }
}

struct AnnuallySleepView: View {
    
    var body: some View {
        Text("Annyally Sleep View")
    }
}

struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        SleepView()
    }
}
