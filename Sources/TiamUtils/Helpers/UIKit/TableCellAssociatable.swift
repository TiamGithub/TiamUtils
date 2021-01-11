import UIKit

/// Conform a UIViewController to this protocol to gain some convenience functions to register and dequeue an associated cell class
/// - Note: Xib file (if used) must have the same name as the associated cell class
/// - Example use case:
/// ````
/// class ViewController: UIViewController, TableCellAssociatable {
///     static let associatedCellClass = MyCell.self
///     let tableView = Self.makeTableView()
///     let dataSource: UITableViewDiffableDataSource<Int, Int>
///
///     init() {
///         self.dataSource = .init(tableView: tableView, cellProvider: { (tv, indexPath, cellinfo) -> UITableViewCell? in
///             let cell = Self.dequeueAssociatedCell(for: tv, indexPath: indexPath)
///             return cell
///         })
///         super.init(nibName: nil, bundle: nil)
///     }
/// }
/// ````
public protocol TableCellAssociatable: UIViewController {
    associatedtype C: UITableViewCell
    static var associatedCellClass: C.Type { get }
    var tableView: UITableView { get }
}

public extension TableCellAssociatable {
    static func dequeueAssociatedCell(for tableView: UITableView, indexPath: IndexPath) -> C {
        return tableView.dequeueReusableCell(Self.associatedCellClass, for: indexPath)
    }

    static func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.registerCell(Self.associatedCellClass)
        return tableView
    }
}
