import SwiftUI

struct SoundsView: View {
    @State private var selectedTab: Tab = .sounds
    
    var body: some View {
        Text("Sounds View")
        
        // BottomNav
        BottomNav(selectedTab: $selectedTab)
    }
}

