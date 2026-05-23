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

    var lastBackupDate: Date? {
        didSet {
            if let date = lastBackupDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "last_backup_date")
            } else {
                UserDefaults.standard.removeObject(forKey: "last_backup_date")
            }
        }
    }

    var autoBackupOnLaunch: Bool {
        didSet {
            UserDefaults.standard.set(autoBackupOnLaunch, forKey: "auto_backup_on_launch")
        }
    }

    private init() {
        let themeRaw = UserDefaults.standard.string(forKey: "app_theme") ?? "system"
        self.theme = AppTheme(rawValue: themeRaw) ?? .system

        let langRaw = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: langRaw) ?? .en

        self.isRecipeEditLocked = UserDefaults.standard.bool(forKey: "is_recipe_edit_locked")
        self.recipePin = UserDefaults.standard.string(forKey: "recipe_pin")

        let interval = UserDefaults.standard.double(forKey: "last_backup_date")
        self.lastBackupDate = interval > 0 ? Date(timeIntervalSince1970: interval) : nil
        self.autoBackupOnLaunch = UserDefaults.standard.bool(forKey: "auto_backup_on_launch")
    }

    private func updateLanguage() {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
    }
}
