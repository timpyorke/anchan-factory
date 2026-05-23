import Foundation

enum GoogleDriveError: LocalizedError {
    case unauthorized
    case forbidden
    case notFound
    case networkError(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Google account session expired. Please sign in again."
        case .forbidden: return "Drive access was denied. Please reconnect your Google account."
        case .notFound: return "The backup file could not be found on Google Drive."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .invalidResponse: return "Received an unexpected response from Google Drive."
        }
    }
}

struct DriveFile: Codable, Identifiable {
    let id: String
    let name: String
    let createdTime: String

    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdTime) ?? ISO8601DateFormatter().date(from: createdTime)
    }
}

actor GoogleDriveService {
    static let shared = GoogleDriveService()
    private init() {}

    private let folderName = "DailyJolly Backups"
    private let baseURL = "https://www.googleapis.com"

    // MARK: - Folder

    func findOrCreateBackupFolder(token: String) async throws -> String {
        let query = "name='\(folderName)' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/drive/v3/files?q=\(encoded)&fields=files(id,name)")!

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await perform(req)
        try check(response)

        struct ListResponse: Decodable { struct File: Decodable { let id: String }; let files: [File] }
        let list = try JSONDecoder().decode(ListResponse.self, from: data)
        if let existing = list.files.first { return existing.id }

        return try await createFolder(token: token)
    }

    private func createFolder(token: String) async throws -> String {
        let url = URL(string: "\(baseURL)/drive/v3/files?fields=id")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["name": folderName, "mimeType": "application/vnd.google-apps.folder"]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await perform(req)
        try check(response)

        struct CreateResponse: Decodable { let id: String }
        return try JSONDecoder().decode(CreateResponse.self, from: data).id
    }

    // MARK: - List

    func listBackups(in folderId: String, token: String) async throws -> [DriveFile] {
        let query = "'\(folderId)' in parents and mimeType='application/json' and trashed=false"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/drive/v3/files?q=\(encoded)&orderBy=createdTime+desc&fields=files(id,name,createdTime)&pageSize=20")!

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await perform(req)
        try check(response)

        struct ListResponse: Decodable { let files: [DriveFile] }
        return try JSONDecoder().decode(ListResponse.self, from: data).files
    }

    // MARK: - Upload

    func upload(data: Data, fileName: String, folderId: String, token: String) async throws -> DriveFile {
        let boundary = UUID().uuidString
        let url = URL(string: "\(baseURL)/upload/drive/v3/files?uploadType=multipart&fields=id,name,createdTime")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let metadata: [String: Any] = ["name": fileName, "mimeType": "application/json", "parents": [folderId]]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata)

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(metadataData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--".data(using: .utf8)!)
        req.httpBody = body

        let (responseData, response) = try await perform(req)
        try check(response)
        return try JSONDecoder().decode(DriveFile.self, from: responseData)
    }

    // MARK: - Download

    func download(fileId: String, token: String) async throws -> Data {
        let url = URL(string: "\(baseURL)/drive/v3/files/\(fileId)?alt=media")!
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await perform(req)
        try check(response)
        return data
    }

    // MARK: - Helpers

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw GoogleDriveError.invalidResponse
            }
            return (data, http)
        } catch let error as GoogleDriveError {
            throw error
        } catch {
            throw GoogleDriveError.networkError(error)
        }
    }

    private func check(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299: return
        case 401: throw GoogleDriveError.unauthorized
        case 403: throw GoogleDriveError.forbidden
        case 404: throw GoogleDriveError.notFound
        default: throw GoogleDriveError.invalidResponse
        }
    }
}
