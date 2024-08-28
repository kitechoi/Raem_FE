//
//  MainContentView.swift
//  GetDatas
//
//  Created by 정현조 on 8/25/24.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedTab: BottomNav.Tab = .home
    @State private var homeView: BedTimeAlarmView.Tab = .none
    @State private var isVisible = true

    var body: some View {
        VStack {
            switch selectedTab {
            case .home:
                if homeView == .none {
                    HomeView()
                } else if homeView == .sleepTrack {
                    SleepTrackingView()
                        .opacity(isVisible ? 1 : 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    isVisible = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    NotificationCenter.default.post(name: Notification.Name("changeHomeView"),
                                                                    object: BedTimeAlarmView.Tab.sleepDetail)
                                    isVisible = true
                                }
                            }
                        }
                } else if homeView == .sleepDetail {
                    SleepDetailView()
                } else {
                    BedTimeAlarmView(selectedTab: $homeView)
                }
            case .sleep:
                SleepView()
            case .sounds:
                SoundsView()
            case .settings:
                SettingView()
            }
            
            Spacer()
            
            BottomNav()
                .frame(maxWidth: .infinity) // BottomNav 전체가 가로로 꽉 차도록 설정
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear{
            NotificationCenter.default.addObserver(forName: Notification.Name("changeHomeView"), object: nil, queue: .main) { notification in
                if let tab = notification.object as? BedTimeAlarmView.Tab {
                    self.homeView = tab
                }
            }
            NotificationCenter.default.addObserver(forName: Notification.Name("changeBottomNav"), object: nil, queue: .main) { notification in
                if let tab = notification.object as? BottomNav.Tab {
                    self.selectedTab = tab
                }
            }
        }
        .onDisappear{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("changeHomeView"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("changeBottomNav"), object: nil)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
