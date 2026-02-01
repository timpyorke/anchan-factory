import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case en = "en"
    case th = "th"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .en: return "English"
        case .th: return "ไทย"
        }
    }

    var flag: String {
        switch self {
        case .en: return "🇺🇸"
        case .th: return "🇹🇭"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
final class AppSettings {
    static let shared = AppSettings()

    var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
        }
    }

    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
            updateLanguage()
        }
    }

    private init() {
        let themeRaw = UserDefaults.standard.string(forKey: "app_theme") ?? "system"
        self.theme = AppTheme(rawValue: themeRaw) ?? .system

        let langRaw = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: langRaw) ?? .en
    }

    private func updateLanguage() {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
    }
}
