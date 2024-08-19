import SwiftUI

struct SleepRatingView: View {
    @State private var rating: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            // 상단 Back 버튼 및 시간 표시
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("backbutton")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.leading, 16)

            // 시간 및 날짜 표시
            Text("22:30 오후")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
            
            Text("5월 5일 일요일")
                .font(.system(size: 18))
                .foregroundColor(.gray)

            Spacer()

            // 수면 별점 평가 섹션
            VStack(spacing: 20) {
                HStack {
                    Text("오늘의 수면은 어땠나요?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        // 액션 추가 (예: 평가 창 닫기)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, 16)

                Text("이 수면 시간은 총 6시간 30분 입니다.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)

                // 별점 선택
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(star <= rating ? .yellow : .gray)
                            .onTapGesture {
                                rating = star
                            }
                    }
                }

                // 기록하기 버튼
                Button(action: {
                    // 기록하기 액션 추가
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
            }
            .padding(.top, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .padding(.horizontal, 16)
            )
            .padding(.bottom, 20)

            Spacer(minLength: 40)

            // 하단 탭 바
            CustomTabBar(selectedTab: .constant(.home))
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct SleepRatingView_Previews: PreviewProvider {
    static var previews: some View {
        SleepRatingView()
    }
}

