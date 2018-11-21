//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootStateControllerDelegate: AnyObject {
    func filterRootStateController(_: FilterRootStateController, shouldChangeVertical vertical: Vertical)
    func filterRootStateControllerShouldShowResults(_: FilterRootStateController)
}

public class FilterRootStateController: UIViewController {
    public enum State {
        case loading
        case filtersOrEmpty
        case filtersLoaded(filter: FilterDataSource)
        case failed(error: FilterRootError, action: FilterRootErrorAction)
    }

    private let navigator: RootFilterNavigator
    private let selectionDataSource: FilterSelectionDataSource
    private let filterSelectionTitleProvider: FilterSelectionTitleProvider
    weak var delegate: FilterRootStateControllerDelegate?

    private lazy var loadingViewController = LoadingViewController(backgroundColor: .white, presentationDelay: 0)

    private lazy var errorViewController = ErrorViewController(backgroundColor: .white, textColor: .licorice, actionTextColor: .primaryBlue)

    private lazy var filterRootViewController: FilterRootViewController = {
        let vc = FilterRootViewController(title: "", navigator: navigator, selectionDataSource: selectionDataSource, filterSelectionTitleProvider: filterSelectionTitleProvider)
        vc.delegate = self
        return vc
    }()

    public var state = State.loading {
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
        errorViewController.remove()

        let viewControllerShown: UIViewController
        switch state {
        case .loading:
            errorViewController.remove()
            add(loadingViewController)
            viewControllerShown = loadingViewController
        case .filtersOrEmpty:
            loadingViewController.remove()
            errorViewController.remove()
            add(filterRootViewController)
            viewControllerShown = filterRootViewController
        case let .filtersLoaded(dataSource):
            loadingViewController.remove()
            errorViewController.remove()
            add(filterRootViewController)
            filterRootViewController.searchQueryFilter = dataSource.searchQuery
            filterRootViewController.preferenceFilters = dataSource.preferences
            filterRootViewController.filters = dataSource.filters
            filterRootViewController.numberOfHits = dataSource.numberOfHits
            filterRootViewController.title = dataSource.filterTitle
            filterRootViewController.verticalsFilters = dataSource.verticals
            viewControllerShown = filterRootViewController
        case let .failed(error, action):
            loadingViewController.remove()
            add(errorViewController)
            handleError(error, action: action)
            viewControllerShown = errorViewController
        }
        title = viewControllerShown.title
    }

    private func handleError(_ error: FilterRootError, action: FilterRootErrorAction) {
        DebugLog.write("Filter root error: \(error)")
        errorViewController.showError(error.errorMessage, actionTitle: action.title, actionCallback: action.action)
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
