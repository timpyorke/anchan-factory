import Foundation
import SwiftData
import GoogleSignIn

@MainActor
final class BackupService {
    static let shared = BackupService()
    private init() {}

    private let serializer = BackupSerializationService.shared
    private let driveService = GoogleDriveService.shared

    // MARK: - Auth

    var isSignedIn: Bool {
        GIDSignIn.sharedInstance.currentUser != nil
    }

    var currentUserEmail: String? {
        GIDSignIn.sharedInstance.currentUser?.profile?.email
    }

    func signIn(presentingViewController: UIViewController) async throws {
        let scopes = ["https://www.googleapis.com/auth/drive.file"]
        do {
            try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: scopes
            )
        } catch {
            throw AppError.authenticationError(error.localizedDescription)
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    func restorePreviousSession() async {
        try? await GIDSignIn.sharedInstance.restorePreviousSignIn()
    }

    // MARK: - Backup

    func performBackup(modelContext: ModelContext) async throws -> DriveFile {
        let token = try await freshToken()
        let document = try serializer.encode(modelContext: modelContext)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(document)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        let timestamp = formatter.string(from: Date.now).replacingOccurrences(of: ":", with: "-")
        let fileName = "DailyJolly_Backup_\(timestamp).json"

        let folderId = try await driveService.findOrCreateBackupFolder(token: token)
        let file = try await driveService.upload(data: data, fileName: fileName, folderId: folderId, token: token)

        AppSettings.shared.lastBackupDate = Date.now
        return file
    }

    // MARK: - List Backups

    func listBackups() async throws -> [DriveFile] {
        let token = try await freshToken()
        let folderId = try await driveService.findOrCreateBackupFolder(token: token)
        return try await driveService.listBackups(in: folderId, token: token)
    }

    // MARK: - Restore

    func performRestore(fileId: String, modelContext: ModelContext) async throws {
        let token = try await freshToken()
        let data = try await driveService.download(fileId: fileId, token: token)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let document: BackupDocument
        do {
            document = try decoder.decode(BackupDocument.self, from: data)
        } catch {
            throw AppError.backupError("Failed to read backup file: \(error.localizedDescription)")
        }

        try serializer.restore(from: document, modelContext: modelContext)
    }

    // MARK: - Token

    private func freshToken() async throws -> String {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw AppError.authenticationError("Not signed in to Google.")
        }
        do {
            try await user.refreshTokensIfNeeded()
        } catch {
            throw AppError.authenticationError("Failed to refresh Google session: \(error.localizedDescription)")
        }
        return user.accessToken.tokenString
    }
}
