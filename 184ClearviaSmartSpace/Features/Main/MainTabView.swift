import SwiftUI

private struct MainTabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<MainTab>? = nil
}

extension EnvironmentValues {
    var mainTabSelection: Binding<MainTab>? {
        get { self[MainTabSelectionKey.self] }
        set { self[MainTabSelectionKey.self] = newValue }
    }
}

struct MainTabView: View {
    @Environment(\.themePalette) private var palette
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .achievements: AchievementsView()
                case .settings: SettingsView()
                }
            }
            .padding(.bottom, 84)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .environment(\.mainTabSelection, $selectedTab)
        .background(Color(palette.background))
    }
}
