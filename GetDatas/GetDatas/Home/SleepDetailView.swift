import SwiftUI

struct SleepDetailView: View {
    @State private var showSleepRatingView = false
    @State private var showBedTimeAlarmView = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            // 상단 Back 버튼
            HStack {
                Button(action: {
                    // Back action
                }) {
                    Image("backbutton")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.leading, 16)

            // 시간과 날짜 표시
            Text("22:30 오후")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
            
            Text("5월 5일 일요일")
                .font(.system(size: 18))
                .foregroundColor(.gray)

            Spacer()

            // 소리 및 음악, 알람 설정 섹션
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "music.note.list")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                    Text("소리 및 음악")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                
                HStack {
                    Image(systemName: "alarm")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                    Text("알람")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Text("12:38AM - 07:30PM")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .onTapGesture {
                    showBedTimeAlarmView = true
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            // 기상 버튼
            Button(action: {
                showSleepRatingView = true
            }) {
                Text("기상")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.deepNavy)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .background(
                NavigationLink(destination: SleepRatingView(), isActive: $showSleepRatingView) {
                    EmptyView()
                }
            )

            // 하단 탭 바
            CustomTabBar(selectedTab: .constant(.home))
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: BedTimeAlarmView(), isActive: $showBedTimeAlarmView) {
                EmptyView()
            }
        )
    }
}

struct SleepDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDetailView()
    }
}

