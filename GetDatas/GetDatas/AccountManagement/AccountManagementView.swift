import SwiftUI

struct AccountManagementView: View {
    @State private var selectedImage: UIImage? = UIImage(systemName: "person.crop.circle.fill")
    @State private var isImagePickerPresented = false
    @State private var showNameChangeView = false
    @State private var showEmailChangeView = false
    @State private var showPasswordChangeView = false
    @State private var showLogoutAlert = false
    @State private var logoutSuccess = false
    @State private var showDeletionAlert = false
    @State private var showAccountDeletionResultAlert = false
    @State private var deletionErrorMessage: String? = nil
    @State private var navigateToLoadingView = false
    
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showRecordView = false
    @State private var showSleepDataView = false
    @EnvironmentObject var bleManager: BLEManager
    @State private var showDemoView = false  // 데모 뷰 전환
    
    var body: some View {
        ScrollView {
            VStack {
                CustomTopBar(title: "계정 관리")
                
                VStack {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        ZStack {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            
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
                .padding(.top, 20) // 상단과 이미지 간의 여백 조정
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
                Spacer().frame(height: 20)
                
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
                        Spacer()
                        Button(action: {
                            showPasswordChangeView = true
                        }) {
                            Text("비밀번호 변경")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        .fullScreenCover(isPresented: $showPasswordChangeView) {
                            PasswordChangeView()
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 16)
                
                HStack {
                    NavigationLink(destination: RecordView(bleManager: bleManager), isActive: $showRecordView) {
                        Button(action: {
                            showRecordView = true
                        }) {
                            Text("실시간 데이터")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.deepNavy)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(destination: SleepDataView(), isActive: $showSleepDataView) {
                        Button(action: {
                            showSleepDataView = true
                        }) {
                            Text("수면 데이터")
                                .foregroundColor(Color.deepNavy)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.deepNavy)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20) // 하단 여백 추가
                
                Spacer()
                
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
                                    navigateToLoadingView = true
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
                    
                    Spacer()
                    
                    Button(action: {
                        // 탈퇴 작업을 바로 시작
                        sessionManager.deleteAccount { success, errorMessage in
                            if success {
                                DispatchQueue.main.async {
                                    deletionErrorMessage = nil
                                    showAccountDeletionResultAlert = true
                                }
                            } else {
                                DispatchQueue.main.async {
                                    deletionErrorMessage = errorMessage
                                    showAccountDeletionResultAlert = true
                                }
                            }
                        }
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
                    .alert(isPresented: $showAccountDeletionResultAlert) {
                        if deletionErrorMessage == nil {
                            return Alert(
                                title: Text("탈퇴 성공"),
                                message: Text("성공적으로 탈퇴되었습니다."),
                                dismissButton: .default(Text("확인")) {
                                    navigateToLoadingView = true
                                }
                            )
                        } else {
                            return Alert(
                                title: Text("탈퇴 실패"),
                                message: Text(deletionErrorMessage ?? "알 수 없는 오류"),
                                dismissButton: .default(Text("닫기"))
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                
                NavigationLink(destination: LoadingView(), isActive: $navigateToLoadingView) {
                    EmptyView()
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
        // Demo 페이지 이동 버튼 추가
        NavigationLink(destination: DemoView(), isActive: $showDemoView) {
            Button(action: {
                showDemoView = true
            }) {
                Text("데모 페이지")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
    }
    
    func logout() {
        sessionManager.logout()
        logoutSuccess = true
        showLogoutAlert = true
    }
}
