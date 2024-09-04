//// DocumentPicker.swift
////  UIKit을 SwiftUI에서 사용 가능하게 하는 구조체. 파일 저장 시 사용. 여러 뷰에서 사용 가능함.
//
//import SwiftUI
//import UIKit
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    let fileURL: URL
//    let onComplete: (Bool) -> Void
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(onComplete: onComplete)
//    }
//    
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let onComplete: (Bool) -> Void
//
//        init(onComplete: @escaping (Bool) -> Void) {
//            self.onComplete = onComplete
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            onComplete(true)
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            onComplete(false)
//        }
//    }
//}
