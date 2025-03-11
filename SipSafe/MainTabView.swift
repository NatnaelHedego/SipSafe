import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CheckInView()
                .tabItem {
                    Label("Check-In", systemImage: "calendar.badge.clock")
                }

            NotiView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
        }
    }
}
