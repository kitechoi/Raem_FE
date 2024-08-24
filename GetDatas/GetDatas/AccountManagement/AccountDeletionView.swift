import SwiftUI

struct AccountDeletionView: View {
    @State private var isAgreed = false
    @State private var showConfirmationAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            // 상단 Back 버튼 및 타이틀
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

            Text("탈퇴하기")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 16)

            Spacer().frame(height: 20)

            // 탈퇴 안내 문구
            Text("탈퇴 전에 아래 내용을 꼭 확인해주세요.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                Text("1. 지금 탈퇴하시면 더 이상 해당 아이디로 로그인 할 수 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)

                Text("2. 계정 삭제 요청 후 계정과 모든 정보가 영구적으로 삭제되어 정보를 가져올 수 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 동의 체크박스
            HStack {
                Button(action: {
                    isAgreed.toggle()
                }) {
                    Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isAgreed ? .mint : .gray)
                }
                Text("위 내용을 모두 확인하였으며, 이에 동의합니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)

            Spacer()

            // 취소 및 탈퇴하기 버튼
            HStack(spacing: 16) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("취소")
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.deepNavy)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showConfirmationAlert = true
                }) {
                    Text("탈퇴하기")
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isAgreed ? Color.gray : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isAgreed)
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(title: Text("계정 탈퇴"),
                          message: Text("정말로 계정을 탈퇴하시겠습니까?"),
                          primaryButton: .destructive(Text("탈퇴하기")) {
                              // 탈퇴 실행 액션
                          },
                          secondaryButton: .cancel(Text("취소")))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            Spacer(minLength: 20)

            // 하단 탭 바
            BottomNav(selectedTab: .constant(.home))
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}

struct AccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDeletionView()
    }
}

