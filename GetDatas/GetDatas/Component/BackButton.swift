import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Button(action: {
                if presentationMode.wrappedValue.isPresented {
                    // 뒤로 가기 동작을 수행
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image("backbutton")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.leading, 16)
    }
}
