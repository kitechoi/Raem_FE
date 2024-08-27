import SwiftUI

struct AccountManagementView: View {
    @State private var selectedImage: UIImage? = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지
    @State private var isImagePickerPresented = false
    @State private var showNameChangeView = false
    
    @State private var showAccountDeletionView = false  // 탈퇴 페이지로 이동하기 위한 상태
    @State private var showEmailChangeView = false // 이메일 변경 뷰로 이동하기 위한 상태
    @State private var showPasswordChangeView = false // 비밀번호 변경 뷰로 이동하기 위한 상태
    
    @State private var savedPassword: String = "********" // 현재 비밀번호 상태 (일반적으로 비밀번호는 서버에서 가져오지 않음)
    
    @State private var isLoggedOut = false  // 로그아웃 상태를 관리하는 변수
    @State private var showLogoutAlert = false  // 로그아웃 후 알림 표시 여부
    @State private var logoutSuccess = false  // 로그아웃 성공 여부
    
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showRecordView = false
    @State private var showSleepDataView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // 상단 타이틀 및 뒤로가기 버튼
                CustomTopBar(title: "계정 관리")
                Spacer()
                
                // 프로필 이미지 및 변경 버튼
                VStack {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        ZStack {
                            Image(uiImage: selectedImage!)
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
                        Text(sessionManager.username)
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        Button(action: {
                            showNameChangeView = true
                        }) {
                            Text("변경")
                                .font(.system(size: 16))
                                .foregroundColor(.mint)
                        }
                        .fullScreenCover(isPresented: $showNameChangeView) {
                            NameChangeView(currentName: $sessionManager.username)
                        }
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
                        Text(sessionManager.email)
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        Button(action: {
                            showEmailChangeView = true
                        }) {
                            Text("변경")
                                .font(.system(size: 16))
                                .foregroundColor(.mint)
                        }
                        .fullScreenCover(isPresented: $showEmailChangeView) {
                            EmailChangeView(currentEmail: $sessionManager.email)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    
                    HStack {
                        Spacer()  // 버튼을 우측 정렬하기 위한 Spacer

                        Button(action: {
                            showPasswordChangeView = true
                        }) {
                            Text("비밀번호 변경")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        .fullScreenCover(isPresented: $showPasswordChangeView) {
                            PasswordChangeView(savedPassword: $savedPassword)
                        }
                    }
                    .padding() // 버튼 주변에 여백을 추가
                }
                .padding(.horizontal, 16)
                
                // 실시간 데이터와 수면 데이터 버튼 섹션
                HStack {
                    NavigationLink(destination: RecordView(), isActive: $showRecordView) {
                        Button(action: {
                            showRecordView = true
                        }) {
                            Text("실시간 데이터")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(destination: SleepDataView(), isActive: $showSleepDataView) {
                        Button(action: {
                            showSleepDataView = true
                        }) {
                            Text("수면 데이터")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
               
                // 로그아웃 및 탈퇴하기 버튼
                HStack {
                    Button(action: {
                        logout()
                    }) {
                        Text("로그아웃")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.red)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        if logoutSuccess {
                            return Alert(
                                title: Text("로그아웃 성공"),
                                message: Text("성공적으로 로그아웃되었습니다."),
                                dismissButton: .default(Text("확인")) {
                                    isLoggedOut = true
                                }
                            )
                        } else {
                            return Alert(
                                title: Text("로그아웃 실패"),
                                message: Text("로그아웃에 실패했습니다. 다시 시도해주세요."),
                                dismissButton: .default(Text("확인"))
                            )
                        }
                    }
                    .fullScreenCover(isPresented: $isLoggedOut) {
                        // 로그아웃 후 이동할 뷰 지정
                        LoadingView()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAccountDeletionView = true  // 탈퇴 페이지로 이동
                    }) {
                        Text("탈퇴하기")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 100/255, green: 110/255, blue: 120/255))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 200/255, green: 200/255, blue: 205/255), lineWidth: 1)
                            )
                    }
                    .fullScreenCover(isPresented: $showAccountDeletionView) {
                        AccountDeletionView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func logout() {
        sessionManager.logout()
        logoutSuccess = true
        showLogoutAlert = true
    }
}

struct AccountManagementView_Previews: PreviewProvider {
    static var previews: some View {
        AccountManagementView()
            .environmentObject(SessionManager())
    }
}
