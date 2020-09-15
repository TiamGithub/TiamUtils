import Foundation

public extension FileManager {
    /// Currently available storage space on the volume used by your app
    /// - Returns: Capacity in Bytes, or nil if not found
    static func currentlyAvailableStorageCapacity() -> Int? {
        let url = URL.cacheDirectory
        guard let capacity = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey]).volumeAvailableCapacity else {
            print("Capacity is unavailable")
            return nil
        }
        return capacity
    }

    /// Storage space that can be made available by the system on the volume used by your app
    /// - Parameter isImportant:
    ///   - if `true`: capacity for storing important required resources
    ///   - if `false`: capacity for storing nonessential opportunistic resources
    /// - Returns: Capacity in Bytes, or nil if not found
    static func potentiallyAvailableStorageCapacity(forImportantUsage isImportant: Bool) -> Int64? {
        let url = URL.cacheDirectory
        let key: URLResourceKey = isImportant
            ? .volumeAvailableCapacityForImportantUsageKey
            : .volumeAvailableCapacityForOpportunisticUsageKey
        let keyPath: KeyPath<URLResourceValues, Int64?> = isImportant
            ? \.volumeAvailableCapacityForImportantUsage
            : \.volumeAvailableCapacityForOpportunisticUsage

        guard let capacity = try? url.resourceValues(forKeys: [key])[keyPath: keyPath] else {
            print("Capacity is unavailable")
            return nil
        }
        return capacity
    }

    /// Creates a new temporary directory ready for use
    func createUniqueTemporaryDirectory() throws -> URL  {
        let component =  Bundle.main.bundleIdentifier ?? "unknown"
        let appropriateURL = URL.temporaryDirectory.appendingPathComponent(component, isDirectory: true)
        return try self.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: appropriateURL, create: true)
    }
}
