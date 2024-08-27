import SwiftUI

struct NameChangeView: View {
    @State private var newName: String = ""
    @Binding var currentName: String
    @Environment(\.presentationMode) var presentationMode // 이전 화면으로 돌아가기 위해 사용

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            CustomTopBar(title: "닉네임 변경")
            Spacer()
                .frame(height: 40) // 충분한 여백 추가
            
            // 이름 입력 필드
            VStack(alignment: .leading) {
                Text("이름")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("사용하실 닉네임 입력", text: $newName)
                        .padding(.vertical, 8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray)
                            , alignment: .bottom
                        )
                    
                    // "X" 버튼
                    if !newName.isEmpty {
                        Button(action: {
                            newName = "" // 입력된 텍스트를 지움
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
                .frame(height: 20)
            
            // 변경 버튼
            Button(action: {
                currentName = newName // 변경된 이름을 반영
                presentationMode.wrappedValue.dismiss() // AccountManagementView로 돌아감
            }) {
                Text("변경")
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newName.isEmpty ? Color.gray.opacity(0.2) : Color.blue) // 텍스트 입력 시 파란색
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .disabled(newName.isEmpty) // 텍스트가 없으면 버튼 비활성화
            
            Spacer() // 하단 여백 추가
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct NameChangeView_Previews: PreviewProvider {
    static var previews: some View {
        NameChangeView(currentName: .constant("잠만보"))
    }
}

