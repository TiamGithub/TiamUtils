import Foundation

public extension DispatchQueue {
    /// Dispatch `work` asynchronously on the main queue if currently running on another thread, or synchronously if already running on the main thread
    static func mainAsyncIfNeeded(
        group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping () -> Void)
    {
        if Thread.isMainThread {
            work()
        } else {
            Self.main.async(group: group, qos: qos, flags: flags, execute: work)
        }
    }

    /// Dispatch `work` synchronously on the main queue while avoiding deadlocks if calling from the main thread
    static func mainSyncIfNeeded<T>(execute work: () -> T) -> T {
        if Thread.isMainThread {
            return work()
        } else {
            return Self.main.sync(execute: work)
        }
    }
}
