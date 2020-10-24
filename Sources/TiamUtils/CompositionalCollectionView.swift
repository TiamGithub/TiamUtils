import UIKit

/// A compositional collection view with strongly typed cell, header(optional) and footer(optional) classes, a corresponding diffable data source and prefetching support(optional)
///
/// Code exemple:
/// ````
/// class ViewController: UIViewController {
///     private let dataSource: UICollectionViewDiffableDataSource<Int, Int>
///     private let viewModel: ViewModel
///     private let collectionView = CompositionalCollectionView(
///         layout: Self.makeCompositionaLayout(),
///         cellClass: CollectionCell.self,
///         headerClass: CollectionHeader.self)
///
///     init(viewModel: ViewModel) {
///         self.viewModel = viewModel
///
///         self.dataSource = collectionView.makeDiffableDataSource(configureCell: { cv, cell, indexPath, itemInfo in
///             // configure the `cell` here using the viewModel
///         }, configureHeader: { cv, header, indexPath in
///             // configure the `header` here using the viewModel
///         }, prefetchCallback: { cv, type, indexPaths in
///             switch type {
///             case .fetch: // prefetch data using the viewModel
///             case .cancel: // cancel prefetching
///             }
///         })
///
///         super.init(nibName: nil, bundle: nil)
///     }
///
///     private static func makeCompositionaLayout() -> UICollectionViewCompositionalLayout {
///         // setup and return a Compositional Layout here
///     }
/// }
/// ````
@available(iOS 13.0, *)
public final class CompositionalCollectionView<C: UICollectionViewCell, H: UICollectionReusableView, F: UICollectionReusableView>: UICollectionView {
    public enum PrefetchCallbackType {
        case fetch, cancel
    }

    #if DEBUG
    internal let hasRegistered: (header: Bool, footer: Bool)
    #endif

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Designated initialisers that automatically registers cell and supplementary view
    /// - Parameters:
    ///   - layout: a compositional layout
    ///   - cellClass: a mandatory cell class
    ///   - headerClass: an optional header class
    ///   - footerClass: an optional footer class
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

    /// Builds a strongly typed diffable dat source specialized for the current collection view
    /// - Parameters:
    ///   - configureCell: Callback to configure the cell
    ///    - cv: the current compositional collection view
    ///    - cell: the dequeued cell to configure
    ///    - indexPAth: the dequeued cell indexPath
    ///    - cellIdentifier: the unique identifier provided by the diffable data source
    ///   - configureHeader: Optional callback to configure the header
    ///   - configureFooter: Optional callback to configure the footer
    ///   - prefetchCallback: Optional prefetching callback
    /// - Returns: The dataSource and prefetchDataSource(if requested) for the current collection view
    /// - Note: You must keep a strong reference to this object
    public func makeDiffableDataSource<SI: Hashable, II: Hashable>(
        configureCell: @escaping (_ cv: Self, _ cell: C, _ indexPath: IndexPath, _ cellIdentifier: II) -> Void,
        configureHeader: ((CompositionalCollectionView<C, H, F>, H, IndexPath) -> Void)? = nil,
        configureFooter: ((CompositionalCollectionView<C, H, F>, F, IndexPath) -> Void)? = nil,
        prefetchCallback: ((CompositionalCollectionView<C, H, F>, PrefetchCallbackType, [IndexPath]) -> Void)? = nil)
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

    /// A specialized diffable data source that supports prefetching and dequeuing cells, headers & footers
    final private class DiffableDataSource<SI: Hashable, II: Hashable>: UICollectionViewDiffableDataSource<SI, II>, UICollectionViewDataSourcePrefetching {

        fileprivate var prefetchCallback: ((CompositionalCollectionView<C, H, F>, PrefetchCallbackType, [IndexPath]) -> Void)? = nil

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
