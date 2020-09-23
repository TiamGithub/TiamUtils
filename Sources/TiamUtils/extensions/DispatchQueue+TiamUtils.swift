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
}
