//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootStateControllerDelegate: AnyObject {
    func filterRootStateController(_: FilterRootStateController, shouldChangeVertical vertical: Vertical)
    func filterRootStateControllerShouldShowResults(_: FilterRootStateController)
}

public class FilterRootStateController: UIViewController {
    enum State {
        case loading
        case filtersLoaded(filter: FilterDataSource)
        case failed(error: FilterRootError)
    }

    private let navigator: RootFilterNavigator
    private let selectionDataSource: FilterSelectionDataSource
    private let filterSelectionTitleProvider: FilterSelectionTitleProvider
    weak var delegate: FilterRootStateControllerDelegate?
    var searchQuerySuggestionDataSource: SearchQuerySuggestionsDataSource?

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .white, presentationDelay: 0)

    private lazy var filterRootViewController: FilterRootViewController = {
        let vc = FilterRootViewController(title: "", navigator: navigator, selectionDataSource: selectionDataSource, filterSelectionTitleProvider: filterSelectionTitleProvider)
        vc.delegate = self
        return vc
    }()

    var state = State.loading {
        didSet {
            if isViewLoaded {
                configure(for: state)
            }
        }
    }

    public init(navigator: RootFilterNavigator, selectionDataSource: FilterSelectionDataSource, filterSelectionTitleProvider: FilterSelectionTitleProvider) {
        self.navigator = navigator
        self.selectionDataSource = selectionDataSource
        self.filterSelectionTitleProvider = filterSelectionTitleProvider
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configure(for: state)
    }

    // MARK: - State handling

    private func configure(for state: State) {
        loadingViewController.remove()

        switch state {
        case .loading:
            add(loadingViewController)
        case let .filtersLoaded(dataSource):
            add(filterRootViewController)
            filterRootViewController.searchQuerySuggestionDataSource = searchQuerySuggestionDataSource
            filterRootViewController.searchQueryFilter = dataSource.searchQuery
            filterRootViewController.preferenceFilters = dataSource.preferences
            filterRootViewController.filters = dataSource.filters
            filterRootViewController.numberOfHits = dataSource.numberOfHits
            filterRootViewController.title = dataSource.filterTitle
            filterRootViewController.verticalsFilters = dataSource.verticals
        case let .failed(error):
            handleError(error)
        }
    }

    private func handleError(_ error: FilterRootError) {
        DebugLog.write("Filter root error: \(error)")
        // TODO:
    }
}

extension FilterRootStateController: FilterRootViewControllerDelegate {
    public func filterRootViewController(_: FilterRootViewController, didChangeVertical vertical: Vertical) {
        state = .loading
        delegate?.filterRootStateController(self, shouldChangeVertical: vertical)
    }

    public func filterRootViewControllerShouldShowResults(_: FilterRootViewController) {
        delegate?.filterRootStateControllerShouldShowResults(self)
    }
}

private extension UIViewController {
    func add(_ childViewController: UIViewController) {
        guard childViewController.parent == nil else { return }

        addChild(childViewController)
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

enum FilterRootError: Error {
}
