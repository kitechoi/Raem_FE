import SwiftUI

struct SleepView: View {
    @State private var selectedTab: Tab = .sleep
    
    var body: some View {
        Text("Sleep View")
        
        // BottomNav
        BottomNav(selectedTab: $selectedTab)
    }
}
