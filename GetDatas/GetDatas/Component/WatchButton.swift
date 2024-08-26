//import SwiftUI
//
//struct WatchButton: View {
//    @State private var showFloatingButtons = false
//    
//    var body: some View {
//        // 오른쪽 아래의 원형 버튼 추가
//        ZStack {
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        withAnimation {
//                            showFloatingButtons.toggle()
//                        }
//                    }) {
//                        Image(systemName: "plus")
//                            .font(.system(size: 24))
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.white)
//                            .background(Color.deepNavy)
//                            .cornerRadius(30)
//                            .shadow(radius: 10)
//                    }
//                    .padding()
//                }
//            }
//            .padding(.bottom, 80)
//            
//            // 플로팅 버튼들
//            if showFloatingButtons {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        VStack(alignment: .trailing) {
//                            NavigationLink(destination: RecordView()) {
//                                Text("실시간 데이터")
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.gray)
//                                    .cornerRadius(10)
//                                    .shadow(radius: 5)
//                            }
//                            .padding(.bottom, 0)
//                            
//                            NavigationLink(destination: SleepDataView()) {
//                                Text("수면 데이터")
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.gray)
//                                    .cornerRadius(10)
//                                    .shadow(radius: 5)
//                            }
//                        }
//                        .padding(.trailing, 20)
//                        .padding(.bottom, 160)
//                    }
//                }
//                .transition(.opacity)
//            }
//        }
//    }
//}
//
