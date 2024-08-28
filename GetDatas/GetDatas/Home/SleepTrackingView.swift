import SwiftUI

struct SleepTrackingView: View {
    @State private var isTransitioning = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()

            // 가운데 이미지
            Image("gooddream")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // 적절한 크기로 조정
                .padding(.top, 70)

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
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

