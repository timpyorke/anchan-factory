import Foundation

enum AppError: LocalizedError {
    case databaseError(String)
    case validationError(String)
    case exportError(String)
    case notFound(String)
    case insufficientStock(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "Database Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .exportError(let message):
            return "Export Error: \(message)"
        case .notFound(let message):
            return "\(message) not found"
        case .insufficientStock(let message):
            return "Insufficient Stock: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .databaseError:
            return "Please try again or restart the app."
        case .validationError:
            return "Please check your input and try again."
        case .exportError:
            return "Please check your file permissions and try again."
        case .notFound:
            return "The item may have been deleted."
        case .insufficientStock:
            return "Please add more inventory before manufacturing."
        case .unknown:
            return "Please try again later."
        }
    }
}
