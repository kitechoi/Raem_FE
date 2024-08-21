import SwiftUI

@main
struct GetDatasApp: App {
    var body: some Scene {
        WindowGroup {
            LoadingView()
        }
    }
}

// 공통 스타일

extension View {
    func globalPadding() -> some View {
        self
            .padding(24)
    }
}
