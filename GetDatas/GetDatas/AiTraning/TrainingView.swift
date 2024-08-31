import SwiftUI
import CoreML

struct TrainingView: View {
    @State private var showRecordFileImporter = false
    @State private var showUserFileImporter = false
    @State private var userFileURL: URL?
    @State private var recordFileURL: URL?
    @State private var showFileUploadAlert = false
    @State private var fileUploadMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("파일을 업로드하고 재학습을 시작하세요")
                .font(.headline)
                .padding()
            
            Button("Record CSV(실시간 데이터) 업로드") {
                showRecordFileImporter = true
            }
            .padding()
            .fileImporter(
                isPresented: $showRecordFileImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let selectedFile):
                    recordFileURL = selectedFile.first
                    print("Record 파일 업로드 완료: \(recordFileURL?.path ?? "없음")")
                case .failure(let error):
                    print("파일 선택 실패: \(error.localizedDescription)")
                }
            }
            
            Button("User CSV (수면단계 통데이터) 업로드") {
                showUserFileImporter = true
            }
            .padding()
            .fileImporter(
                isPresented: $showUserFileImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let selectedFile):
                    userFileURL = selectedFile.first
                    print("User 파일 업로드 완료: \(userFileURL?.path ?? "없음")")
                case .failure(let error):
                    print("파일 선택 실패: \(error.localizedDescription)")
                }
            }
            
            Button("DreamAi 재학습 시작") {
                if let recordFileURL = recordFileURL, let userFileURL = userFileURL {
                    let processor = TrainProcessor()
                    processor.preprocessAndTrain(recordFilePath: recordFileURL.path, userFilePath: userFileURL.path)
                } else {
                    fileUploadMessage = "모든 파일을 업로드해야 합니다."
                    showFileUploadAlert = true
                }
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .alert(isPresented: $showFileUploadAlert) {
                Alert(title: Text("파일 업로드 오류"), message: Text(fileUploadMessage), dismissButton: .default(Text("확인")))
            }
        }
        .padding()
    }
}
