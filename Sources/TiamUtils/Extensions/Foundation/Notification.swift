import Foundation

public extension Notification.Name {
    /// Creates a notification name unique to the caller
    ///
    /// Usage:
    /// ````
    /// extension Notification.Name {
    ///     static var myNotificationName: Self { .makeName() }
    /// }
    /// ````
    static func makeName(fileID: String = #fileID, line: Int = #line, function: String = #function) -> NSNotification.Name {
        let notificationName = "\(fileID)|\(String(line))|\(function)"
        return .init(notificationName)
    }
}
