import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case history
        case analytics
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(Tab.home)
            
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == .history ? "clock.fill" : "clock")
                    Text("History")
                }
                .tag(Tab.history)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: selectedTab == .analytics ? "chart.bar.fill" : "chart.bar")
                    Text("Analytics")
                }
                .tag(Tab.analytics)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
        .tint(DesignSystem.Colors.primaryLight)
        .onChange(of: selectedTab) {
            lightHaptic()
        }
    }
    
    private func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
