import Foundation

public extension URL {
    /// Use this directory to store files that the app uses to run but that should remain hidden from the user. This directory can also include data files, configuration files, templates and modified versions of resources loaded from the app bundle.
    /// - Note: The contents of this directory are backed up by iTunes and iCloud.
    static let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

    /// Use this directory to store user-generated content locally. The contents of this directory can be made available to the user through file sharing; therefore, this directory should only contain files that you may wish to expose to the user.
    ///
    /// Content will be accessible in the "Files" app under the  "On my iPhone" section if your "Info.plist" supports "Open in Place" and "File Sharing Enabled"
    /// - Note: The contents of this directory are backed up by iTunes and iCloud.
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    /// Use this directory to store data that can be recreated and that the app does not require to operate properly, but that can improve performance if persisted. The system may delete this directory to free up disk space.
    /// - Note: The contents of this directory are not backed up by iTunes or iCloud.
    static let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    /// Use this directory to write temporary files that do not need to persist between launches of your app. Your app should remove temporary files when they are no longer needed. The system may purge this directory when your app is not running.
    /// - Note: The contents of this directory are not backed up by iTunes or iCloud.
    static let temporaryDirectory = FileManager.default.temporaryDirectory

    /// Reads disk to see if a file at `self.path` exists and if it is a directory
    /// - returns:
    ///   - `(false, false)` if url is not a "`file://`" url, or if it is not accessible, or if it doesn't exist
    ///   - `(true, false)` for regular files
    ///   - `(true, true)` for directories
    func fileAtPath() -> (exists: Bool, isDirectory: Bool) {
        var isDir: ObjCBool = false
        guard isFileURL && FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) else {
            return (exists: false, isDirectory: false)
        }
        return (exists: true, isDirectory: isDir.boolValue)
    }

    /// Prevents file from being backed up to iCloud and iTunes
    func excludeFromBackup() throws {
        guard isFileURL && FileManager.default.fileExists(atPath: self.path) else {
            return
        }
        try (self as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
    }
}