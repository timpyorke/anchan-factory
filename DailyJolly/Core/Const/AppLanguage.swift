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
