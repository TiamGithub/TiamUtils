import UIKit

extension UITableViewCell: ReusableIdentifier {}

extension UITableViewHeaderFooterView: ReusableIdentifier {}

public extension UITableView {
    /// Xib file (if used) must have the same name as the class
    func register<T: UITableViewCell>(_ viewClass: T.Type) {
        let bundle = Bundle(for: viewClass)
        let nibName = String(describing: viewClass)
        let nibExists = bundle.path(forResource: nibName, ofType: "nib") != nil

        if nibExists {
            register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: viewClass.reuseIdentifier)
        } else {
            register(viewClass, forCellReuseIdentifier: viewClass.reuseIdentifier)
        }
    }
}
