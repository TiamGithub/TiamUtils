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

@available(iOS 13.0, *)
public extension NSCollectionLayoutDimension {
    class var fullWidth: Self {
        .fractionalWidth(1)
    }

    class var fullHeight: Self {
        .fractionalHeight(1)
    }
}

@available(iOS 13.0, *)
public extension NSCollectionLayoutSize {
    class var fullRect: Self {
        .init(widthDimension: .fullWidth, heightDimension: .fullHeight)
    }

    convenience init(widthDimension: NSCollectionLayoutDimension) {
        self.init(widthDimension: widthDimension, heightDimension: .fullHeight)
    }

    convenience init(heightDimension: NSCollectionLayoutDimension) {
        self.init(widthDimension: .fullWidth, heightDimension: heightDimension)
    }
}

@available(iOS 13.0, *)
public extension NSCollectionLayoutItem {
    class var fullRect: Self {
        .init(layoutSize: .fullRect)
    }
}
