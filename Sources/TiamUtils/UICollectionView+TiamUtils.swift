import UIKit

extension UICollectionReusableView: ReusableIdentifier {}

public extension UICollectionView {
    enum Item {
        case cell
        case supplementary (SupplementaryItem)
    }

    enum SupplementaryItem: String {
        case header, footer
    }

    func register<T: UICollectionReusableView>(_ item: Item, ofType viewClass: T.Type) {
        let bundle = Bundle(for: viewClass)
        let nibName = NSStringFromClass(viewClass)
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

    func dequeueReusable<T: UICollectionReusableView>(_ item: Item, for indexPath: IndexPath) -> T {
        switch item {
        case .cell:
            return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
        case .supplementary(let kind):
            return dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
        }
    }
}
