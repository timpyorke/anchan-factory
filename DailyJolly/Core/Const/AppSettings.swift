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

    var isRecipeEditLocked: Bool {
        didSet {
            UserDefaults.standard.set(isRecipeEditLocked, forKey: "is_recipe_edit_locked")
        }
    }

    var recipePin: String? {
        didSet {
            UserDefaults.standard.set(recipePin, forKey: "recipe_pin")
        }
    }

    private init() {
        let themeRaw = UserDefaults.standard.string(forKey: "app_theme") ?? "system"
        self.theme = AppTheme(rawValue: themeRaw) ?? .system

        let langRaw = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: langRaw) ?? .en

        self.isRecipeEditLocked = UserDefaults.standard.bool(forKey: "is_recipe_edit_locked")
        self.recipePin = UserDefaults.standard.string(forKey: "recipe_pin")
    }

    private func updateLanguage() {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
    }
}
