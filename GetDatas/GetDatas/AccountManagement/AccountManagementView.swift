import SwiftUI

struct AccountManagementView: View {
    @State private var selectedImage: UIImage? = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지
    @State private var isImagePickerPresented = false
    @State private var showNameChangeView = false
    @State private var showEmailChangeView = false // 이메일 변경 뷰로 이동하기 위한 상태
    @State private var showPasswordChangeView = false // 비밀번호 변경 뷰로 이동하기 위한 상태
    @State private var currentName: String = "잠만보"
    @State private var currentEmail: String = "zammanbo111@duksung.ac.kr" // 현재 이메일 상태
    @State private var savedPassword: String = "********" // 현재 비밀번호 상태
    @State private var showAccountDeletionView = false  // 탈퇴 페이지로 이동하기 위한 상태

    var body: some View {
        VStack {
            // 상단 타이틀 및 뒤로가기 버튼
            HStack {
                Button(action: {
                    // 뒤로가기 액션
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                }
                Spacer()
                Text("계정 관리")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                // 오른쪽 여백 확보를 위한 빈 공간
                Image(systemName: "chevron.left")
                    .foregroundColor(.clear)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // 프로필 이미지 및 변경 버튼
            VStack {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    ZStack {
                        Image(uiImage: selectedImage ?? UIImage(systemName: "person.crop.circle.fill")!)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        // 사진 변경 아이콘
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.mint)
                            .background(Circle().fill(Color.white))
                            .offset(x: 35, y: 35)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            
            Spacer()
                .frame(height: 20)
            
            // 이름, 이메일, 비밀번호 변경 섹션
            VStack(spacing: 16) {
                HStack {
                    Text("이름")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(currentName)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showNameChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: NameChangeView(currentName: $currentName), isActive: $showNameChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
                
                HStack {
                    Text("이메일")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(currentEmail) // 변경된 이메일이 반영됨
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showEmailChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: EmailChangeView(currentEmail: $currentEmail), isActive: $showEmailChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
                
                HStack {
                    Text("비밀번호")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(savedPassword) // 현재 저장된 비밀번호 표시
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    Button(action: {
                        showPasswordChangeView = true
                    }) {
                        Text("변경")
                            .font(.system(size: 16))
                            .foregroundColor(.mint)
                    }
                    .background(
                        NavigationLink(destination: PasswordChangeView(savedPassword: $savedPassword), isActive: $showPasswordChangeView) {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // 로그아웃 및 탈퇴하기 버튼
            HStack {
                Button(action: {
                    // 로그아웃 액션
                }) {
                    Text("로그아웃")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    showAccountDeletionView = true  // 탈퇴 페이지로 이동
                }) {
                    Text("탈퇴하기")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .background(
                    NavigationLink(destination: AccountDeletionView(), isActive: $showAccountDeletionView) {
                        EmptyView()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct AccountManagementView_Previews: PreviewProvider {
    static var previews: some View {
        AccountManagementView()
    }
}

