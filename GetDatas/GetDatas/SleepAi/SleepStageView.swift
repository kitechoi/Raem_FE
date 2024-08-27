//import SwiftUI
//
//struct SleepStageView: View {
//    @StateObject private var viewModel = SleepStageViewModel()
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack {
//            Text("Predicted Sleep Stages")
//                .font(.title)
//                .padding()
//
//            List(viewModel.predictedResults) { result in
//                HStack {
//                    Text(result.timestamp)
//                        .font(.body)
//                    Spacer()
//                    Text("\(result.stage)")
//                        .font(.headline)
//                }
//            }
//            
//            if let errorMessage = errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            NotificationCenter.default.addObserver(forName: .predictedSleepStage, object: nil, queue: .main) { notification in
//                if let error = notification.userInfo?["error"] as? String {
//                    errorMessage = error
//                }
//            }
//        }
//    }
//}
//
//struct SleepStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        SleepStageView()
//    }
//}
