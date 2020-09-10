import UIKit

@available(iOS 13.0, *)
public extension NSCollectionLayoutBoundarySupplementaryItem {
    convenience init(layoutSize: NSCollectionLayoutSize, kind: UICollectionView.SupplementaryItem) {
        switch kind {
        case .header:
            self.init(layoutSize: layoutSize, elementKind: kind.rawValue, alignment: .top)
        case .footer:
            self.init(layoutSize: layoutSize, elementKind: kind.rawValue, alignment: .bottom)
        }
    }
}
