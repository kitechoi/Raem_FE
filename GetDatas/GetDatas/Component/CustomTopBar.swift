import SwiftUI

struct CustomTopBar: View {
    var title: String

    var body: some View {
        HStack {
            BackButton()

            Spacer()

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            Spacer() // 이 Spacer는 왼쪽 아이콘의 여백을 맞추기 위한 용도입니다.

            // 이 빈 공간을 차지하는 뷰를 추가하여 양쪽 간격을 동일하게 맞출 수 있습니다.
            // 이 뷰는 보이지 않으며 크기는 BackButton과 동일하게 만들어 줍니다.
            BackButton()
                .opacity(0)
        }
        .padding(.top, 60)
        .background(Color.white)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarHidden(true)
    }
}
