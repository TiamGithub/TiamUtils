import UIKit

public extension UITableView {
    /// Registers a cell and automatically choose an identifier and the appropriate method (i.e. UINib or Metatype)
    /// - Note: Xib file (if used) must have the same name as the class
    func registerCell<T: UITableViewCell>(_ viewClass: T.Type) {
        let bundle = Bundle(for: viewClass)
        let nibName = String(describing: viewClass)
        let nibExists = bundle.path(forResource: nibName, ofType: "nib") != nil

        if nibExists {
            register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: viewClass.reuseIdentifier)
        } else {
            register(viewClass, forCellReuseIdentifier: viewClass.reuseIdentifier)
        }
    }

    /// Dequeue a cell of type `T` previously registered with `registerCell<T>(_: T.Type)`
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Misconfigured cell type, \(cellClass)!")
        }
        return cell
    }
}
