import UIKit

public extension UICollectionView {
    enum Item {
        case cell
        case supplementary (SupplementaryItem)
    }

    enum SupplementaryItem: String {
        case header, footer
    }

    /// Registers a cell or supplementary view with its corresponding Nib if found in the Bundle, or with its metatype
    /// - Parameters:
    ///   - item: cell or header or footer
    ///   - viewClass: the view's metatype
    /// - Note: Xib file (if used) must have the same name as the class
    func register<T: UICollectionReusableView>(_ item: Item, ofType viewClass: T.Type) {
        let bundle = Bundle(for: viewClass)
        let nibName = String(describing: viewClass)
        let nibExists = bundle.path(forResource: nibName, ofType: "nib") != nil

        switch (nibExists, item) {
        case (true, .cell):
            register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: viewClass.reuseIdentifier)
        case (true, .supplementary(let kind)):
            register(UINib(nibName: nibName, bundle: bundle), forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: viewClass.reuseIdentifier)
        case (false, .cell):
            register(viewClass, forCellWithReuseIdentifier: viewClass.reuseIdentifier)
        case (false, .supplementary(let kind)):
            register(viewClass, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: viewClass.reuseIdentifier)
        }
    }

    /// Dequeue a reusable view registered with `register<T>(_:ofType:)`
    /// - Parameters:
    ///   - item: cell or header or footer
    func dequeueReusable<T: UICollectionReusableView>(_ item: Item, for indexPath: IndexPath) -> T {
        switch item {
        case .cell:
            return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
        case .supplementary(let kind):
            return dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
        }
    }
}
