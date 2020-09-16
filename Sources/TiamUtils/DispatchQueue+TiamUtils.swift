import Foundation

public extension DispatchQueue {
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

//public extension OS_dispatch_queue_main {
//    func asyncIfNeeded(
//        group: DispatchGroup? = nil,
//        qos: DispatchQoS = .unspecified,
//        flags: DispatchWorkItemFlags = [],
//        execute work: @escaping () -> Void)
//    {
//        if Thread.isMainThread {
//            work()
//        } else {
//            self.async(group: group, qos: qos, flags: flags, execute: work)
//        }
//    }
//}
