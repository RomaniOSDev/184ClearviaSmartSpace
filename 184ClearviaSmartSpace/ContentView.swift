import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var progress = ProgressStore()
    @StateObject private var themeStore = ThemeStore()

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabView()
                    .id(themeStore.theme.rawValue)
            } else {
                OnboardingView()
            }
        }
        .environmentObject(progress)
        .environmentObject(themeStore)
        .environment(\.themePalette, themeStore.palette)
        .preferredColorScheme(.dark)
        .onAppear { themeStore.sync(from: progress) }
    }
}

#Preview {
    ContentView()
}
