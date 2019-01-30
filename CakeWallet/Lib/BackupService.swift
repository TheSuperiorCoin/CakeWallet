import Foundation

protocol BackupService {
    func export(withPassword password: String) throws -> Data
    func `import`(from url: URL, withPassword password: String) throws
}
