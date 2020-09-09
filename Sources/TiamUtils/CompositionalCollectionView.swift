import UIKit

@available(iOS 13.0, *)
public class CompositionalCollectionView<C: UICollectionViewCell, H: UICollectionReusableView, F: UICollectionReusableView>: UICollectionView {
    #if DEBUG
    private let hasRegistered: (header: Bool, footer: Bool)
    #endif

    public init(layout: UICollectionViewCompositionalLayout, cellClass: C.Type, headerClass: H.Type? = nil, footerClass: F.Type? = nil) {
        #if DEBUG
        self.hasRegistered = (headerClass != nil, footerClass != nil)
        #endif

        super.init(frame: .zero, collectionViewLayout: layout)

        self.register(.cell, ofType: cellClass)
        if let headerClass = headerClass {
            register(.supplementary(.header), ofType: headerClass)
        }
        if let footerClass = footerClass {
            register(.supplementary(.footer), ofType: footerClass)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func makeDiffableDataSource<SI: Hashable, II: Hashable>(
        configureCell: @escaping (Self, C, IndexPath, II) -> Void,
        configureHeader: ((CompositionalCollectionView<C, H, F>, H, IndexPath) -> Void)? = nil,
        configureFooter: ((CompositionalCollectionView<C, H, F>, F, IndexPath) -> Void)? = nil,
        prefetchCallback: ((CompositionalCollectionView<C, H, F>, DiffableDataSource<SI, II>.CallbackType, [IndexPath]) -> Void)? = nil)
    -> UICollectionViewDiffableDataSource<SI, II> {
        #if DEBUG
        assert(hasRegistered.header == (configureHeader != nil), hasRegistered.header ? "Header configuration needed" : "No header registered")
        assert(hasRegistered.footer == (configureFooter != nil), hasRegistered.footer ? "Footer configuration needed" : "No footer registered")
        #endif

        let diffableDataSource = DiffableDataSource<SI, II>(
            collectionView: self,
            cellProvider: { cv, indexPath, itemInfo in
                let ccv = cv as! Self
                let cell: C = ccv.dequeueReusable(.cell, for: indexPath)
                configureCell(ccv, cell, indexPath, itemInfo)
                return cell
            })

        if configureHeader != nil || configureFooter != nil {
            diffableDataSource.supplementaryViewProvider = { cv, supplementaryKind, indexPath in
                guard let supplementaryItem = SupplementaryItem(rawValue: supplementaryKind) else {
                    fatalError("Misconfigured supplementary type!")
                }
                let ccv = cv as! Self
                switch supplementaryItem {
                case .header:
                    let header: H = ccv.dequeueReusable(.supplementary(.header), for: indexPath)
                    configureHeader?(ccv, header, indexPath)
                    return header
                case .footer:
                    let footer: F = ccv.dequeueReusable(.supplementary(.footer), for: indexPath)
                    configureFooter?(ccv, footer, indexPath)
                    return footer
                }
            }
        }

        if let prefetch = prefetchCallback {
            diffableDataSource.prefetchCallback = prefetch
            self.prefetchDataSource = diffableDataSource
        }

        return diffableDataSource
    }

    public class DiffableDataSource<SI: Hashable, II: Hashable>: UICollectionViewDiffableDataSource<SI, II>, UICollectionViewDataSourcePrefetching {
        public enum CallbackType {
            case fetch, cancel
        }

        fileprivate var prefetchCallback: ((CompositionalCollectionView<C, H, F>, CallbackType, [IndexPath]) -> Void)? = nil

        public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            let ccv = collectionView as! CompositionalCollectionView<C, H, F>
            prefetchCallback?(ccv, .fetch, indexPaths)
        }

        public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            let ccv = collectionView as! CompositionalCollectionView<C, H, F>
            prefetchCallback?(ccv, .cancel, indexPaths)
        }
    }
}
