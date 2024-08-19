import SwiftUI

struct SleepTrackingView: View {
    @State private var isTransitioning = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            // 상단 Back 버튼
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

            // 가운데 이미지
            Image("gooddream")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // 적절한 크기로 조정

            // 타이틀 및 설명
            VStack(spacing: 8) {
                Text("좋은 꿈 꾸세요!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("수면 추적을 시작합니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            // 하단 탭 바
            CustomTabBar(selectedTab: .constant(.home))
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isTransitioning = true
            }
        }
        .background(
            NavigationLink(destination: SleepDetailView(), isActive: $isTransitioning) {
                EmptyView()
            }
        )
    }
}

