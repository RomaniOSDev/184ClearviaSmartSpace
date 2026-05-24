import SwiftUI
import Combine

struct ThemePalette: Equatable {
    let background: String
    let surface: String
    let primary: String
    let accent: String
    let textPrimary: String
    let textSecondary: String
}

enum AppTheme: String, CaseIterable, Identifiable {
    case classic
    case aurora
    case ember

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .aurora: "Aurora"
        case .ember: "Ember"
        }
    }

    var palette: ThemePalette {
        switch self {
        case .classic:
            ThemePalette(
                background: "AppBackground",
                surface: "AppSurface",
                primary: "AppPrimary",
                accent: "AppAccent",
                textPrimary: "AppTextPrimary",
                textSecondary: "AppTextSecondary"
            )
        case .aurora:
            ThemePalette(
                background: "AppSurface",
                surface: "AppBackground",
                primary: "AppAccent",
                accent: "AppPrimary",
                textPrimary: "AppTextPrimary",
                textSecondary: "AppTextSecondary"
            )
        case .ember:
            ThemePalette(
                background: "AppBackground",
                surface: "AppPrimary",
                primary: "AppAccent",
                accent: "AppSurface",
                textPrimary: "AppTextPrimary",
                textSecondary: "AppTextSecondary"
            )
        }
    }
}

final class ThemeStore: ObservableObject {
    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme") }
    }

    var palette: ThemePalette { theme.palette }

    init() {
        let raw = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.classic.rawValue
        theme = AppTheme(rawValue: raw) ?? .classic
    }

    func sync(from progress: ProgressStore) {
        if let stored = AppTheme(rawValue: progress.selectedThemeRaw) {
            theme = stored
        }
    }
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = AppTheme.classic.palette
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
