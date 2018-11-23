//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootStateControllerDelegate: AnyObject {
    func filterRootStateController(_: FilterRootStateController, shouldChangeVertical vertical: Vertical)
    func filterRootStateControllerShouldShowResults(_: FilterRootStateController)
}

public class FilterRootStateController: UIViewController {
    private enum State {
        case loading
        case filter
        case error
    }

    public enum StateChange {
        case loading
        case filters
        case filtersUpdated(data: FilterDataSource)
        case loadFreshFilters(data: FilterDataSource)
        case newSelectionDataSource(data: FilterSelectionDataSource)
        case failed(error: FilterRootError, action: FilterRootErrorAction)
    }

    private let navigator: RootFilterNavigator
    private var selectionDataSource: FilterSelectionDataSource
    private let filterSelectionTitleProvider: FilterSelectionTitleProvider
    weak var delegate: FilterRootStateControllerDelegate?

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .white, presentationDelay: 0)

    private lazy var errorViewController = ErrorViewController(backgroundColor: .white, textColor: .licorice, actionTextColor: .primaryBlue)

    private lazy var filterRootViewController: FilterRootViewController = {
        let vc = FilterRootViewController(title: "", navigator: navigator, selectionDataSource: selectionDataSource, filterSelectionTitleProvider: filterSelectionTitleProvider, delegate: self)
        return vc
    }()

    private var state = State.loading {
        didSet {
            if isViewLoaded {
                configure(for: state)
            }
        }
    }

    private(set) var currentFilterDataSource: FilterDataSource? {
        didSet {
            filterRootViewController.searchQueryFilter = currentFilterDataSource?.searchQuery
            filterRootViewController.preferenceFilters = currentFilterDataSource?.preferences ?? []
            filterRootViewController.filters = currentFilterDataSource?.filters ?? []
            filterRootViewController.numberOfHits = currentFilterDataSource?.numberOfHits
            filterRootViewController.title = currentFilterDataSource?.filterTitle
            filterRootViewController.verticalsFilters = currentFilterDataSource?.verticals ?? []
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

    public func change(to change: StateChange) {
        switch change {
        case .loading:
            state = .loading
        case .filters:
            state = .filter
        case let .filtersUpdated(dataSource):
            currentFilterDataSource = dataSource
            state = .filter
        case let .loadFreshFilters(dataSource):
            filterRootViewController.remove()
            filterRootViewController = FilterRootViewController(title: "", navigator: navigator, selectionDataSource: selectionDataSource, filterSelectionTitleProvider: filterSelectionTitleProvider, delegate: self)
            currentFilterDataSource = dataSource
            state = .filter
        case let .newSelectionDataSource(newSelectionDataSource):
            selectionDataSource = newSelectionDataSource
            filterRootViewController.selectionDataSource = newSelectionDataSource
        case let .failed(error, action):
            errorViewController.showError(error.errorMessage, actionTitle: action.title, actionCallback: action.action)
            state = .error
        }
    }

    private func configure(for state: State) {
        loadingViewController.remove()
        errorViewController.remove()

        let viewControllerShown: UIViewController
        switch state {
        case .loading:
            errorViewController.remove()
            add(loadingViewController)
            viewControllerShown = loadingViewController
        case .filter:
            loadingViewController.remove()
            errorViewController.remove()
            add(filterRootViewController)
            viewControllerShown = filterRootViewController
        case .error:
            loadingViewController.remove()
            add(errorViewController)
            viewControllerShown = errorViewController
        }
        title = viewControllerShown.title
    }
}

extension FilterRootStateController: FilterRootViewControllerDelegate {
    public func filterRootViewController(_: FilterRootViewController, didChangeVertical vertical: Vertical) {
        delegate?.filterRootStateController(self, shouldChangeVertical: vertical)
    }

    public func filterRootViewControllerShouldShowResults(_: FilterRootViewController) {
        delegate?.filterRootStateControllerShouldShowResults(self)
    }
}

public enum FilterRootError: Error {
    case unableToLoadFilterData
    case undefined

    var errorMessage: String {
        switch self {
        case .undefined:
            return "unkown_error".localized()
        case .unableToLoadFilterData:
            return "unable_to_load_filter_data_error".localized()
        }
    }
}

public enum FilterRootErrorAction {
    case retry(action: () -> Void)
    case ok(action: () -> Void)

    var action: () -> Void {
        switch self {
        case let .retry(action):
            return action
        case let .ok(action):
            return action
        }
    }

    var title: String {
        switch self {
        case .retry:
            return "try_again_button_title".localized()
        case .ok:
            return "ok_button_title".localized()
        }
    }
}
