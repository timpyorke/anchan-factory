import SwiftUI

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
