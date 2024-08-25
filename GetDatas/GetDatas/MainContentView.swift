//
//  MainContentView.swift
//  GetDatas
//
//  Created by 정현조 on 8/25/24.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedTab: BottomNav.Tab = .home

    var body: some View {
        VStack {
            switch selectedTab {
            case .home:
                HomeView()
            case .sleep:
                SleepView()
            case .sounds:
                SoundsView()
            case .settings:
                SettingView()
            }
            
            Spacer()
            
            BottomNav(selectedTab: $selectedTab)
                .frame(maxWidth: .infinity) // BottomNav 전체가 가로로 꽉 차도록 설정
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
