//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FilterRootViewControllerDelegate: AnyObject {
    func filterRootViewController(_: RootFilterViewController, didChangeVertical vertical: Vertical)
    func filterRootViewControllerShouldShowResults(_: RootFilterViewController)
}

public protocol FilterSelectionDelegate: class {
    func filterViewControllerDidChangeSelection(_ viewController: FilterViewController)
}

extension RootFilterViewController {
    enum Section: Int, CaseIterable {
        case searchQuery = 0
        case preferences
        case filters
    }
}

public class RootFilterViewController: UIViewController {
    weak var delegate: FilterRootViewControllerDelegate?
    let selectionDataSource: FilterSelectionDataSource
    let filterDataSource: FilterDataSource
    let filterSelectionTitleProvider: FilterSelectionTitleProvider

    var popoverPresentationTransitioningDelegate: CustomPopoverPresentationTransitioningDelegate?

    public var searchQuerySuggestionDataSource: SearchQuerySuggestionsDataSource? {
        get { return searchViewController.searchQuerySuggestionDataSource }
        set { searchViewController.searchQuerySuggestionDataSource = newValue }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .milk
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(FilterCell.self)

        if UIDevice.isPreiOS11 {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 44
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var showResultsButtonView: FilterBottomButtonView = {
        let buttonView = FilterBottomButtonView()
        buttonView.delegate = self
        buttonView.buttonTitle = showResultsButtonViewTitle()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    private lazy var loadingView: UIView = {
        let coverView = UIView(frame: .zero)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let activityIndicator = UIActivityIndicatorView(style: .white)
        coverView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
        ])
        activityIndicator.startAnimating()
        return coverView
    }()

    lazy var searchViewController: SearchQueryViewController = {
        let searchViewController = SearchQueryViewController()
        searchViewController.delegate = self
        return searchViewController
    }()

    lazy var searchQueryCell: SearchQueryCell = {
        let cell = SearchQueryCell(frame: .zero)
        cell.searchBar = searchViewController.searchBar
        cell.searchBar?.placeholder = filterDataSource.searchQuery?.placeholderText
        return cell
    }()

    lazy var inlineFilterView: InlineFilterView = {
        let preferences = filterDataSource.preferences.filter { !$0.values.isEmpty }
        let view = InlineFilterView(verticals: filterDataSource.verticals, preferences: preferences)
        view.selectionDataSource = selectionDataSource
        view.inlineFilterDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var preferenceCell: InlineFilterCell = {
        let cell = InlineFilterCell(inlineFilterView: inlineFilterView)
        return cell
    }()

    public init(filterDataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, titleProvider: FilterSelectionTitleProvider) {
        self.filterDataSource = filterDataSource
        self.selectionDataSource = selectionDataSource
        filterSelectionTitleProvider = titleProvider
        super.init(nibName: nil, bundle: nil)
        title = filterDataSource.filterTitle
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: -

extension RootFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .searchQuery:
            return
        case .preferences:
            return
        case .filters:
            guard let filterInfo = self.filterInfo(at: indexPath) else { return }
            let viewController: UIViewController?
            switch filterInfo {
            case let listSelectionFilterInfo as ListSelectionFilterInfoType:
                viewController = ListSelectionFilterViewController(filterInfo: listSelectionFilterInfo,
                                                                   dataSource: filterDataSource,
                                                                   selectionDataSource: selectionDataSource)
            case let multiLevelListSelectionFilterInfo as MultiLevelListSelectionFilterInfoType:
                viewController = MultiLevelListSelectionFilterViewController(filterInfo: multiLevelListSelectionFilterInfo,
                                                                             dataSource: filterDataSource,
                                                                             selectionDataSource: selectionDataSource)
            case let rangeFilterInfo as RangeFilterInfoType:
                viewController = RangeFilterViewController(filterInfo: rangeFilterInfo,
                                                           dataSource: filterDataSource,
                                                           selectionDataSource: selectionDataSource)
            case let stepperFilterInfo as StepperFilterInfoType:
                viewController = StepperFilterViewController(filterInfo: stepperFilterInfo,
                                                             dataSource: filterDataSource,
                                                             selectionDataSource: selectionDataSource)
            default:
                viewController = nil
                break
            }
            guard let controller = viewController else { return }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension RootFilterViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .searchQuery:
            return filterDataSource.searchQuery != nil ? 1 : 0
        case .preferences:
            let hasData = !filterDataSource.verticals.isEmpty || !filterDataSource.preferences.isEmpty
            return hasData ? 1 : 0
        case .filters:
            return filterDataSource.filters.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }
        switch section {
        case .searchQuery:
            guard let searchQuery = filterDataSource.searchQuery else { return searchQueryCell }
            searchViewController.searchBar.text = selectionDataSource.value(for: searchQuery)?.first
            return searchQueryCell

        case .preferences:
            return preferenceCell

        case .filters:
            let filterInfo = self.filterInfo(at: indexPath)
            let selectionValues = selectionValuesForFilterComponent(at: indexPath)
            let cell = tableView.dequeue(FilterCell.self, for: indexPath)
            cell.filterName = filterInfo?.title
            cell.selectedValues = selectionValues.map({ SelectionWithTitle(selectionInfo: $0, title: filterSelectionTitleProvider.titleForSelection($0)) })
            cell.accessoryType = .disclosureIndicator
            cell.delegate = self
            return cell
        }
    }
}

extension RootFilterViewController: FilterBottomButtonViewDelegate {
    func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        delegate?.filterRootViewControllerShouldShowResults(self)
    }
}

extension RootFilterViewController: InlineFilterViewDelegate {
    public func inlineFilterView(_ inlineFilterView: InlineFilterView, didTapExpandableSegment segment: Segment) {
        let controller = VerticalListViewController(verticals: filterDataSource.verticals)
        popoverPresentationTransitioningDelegate = CustomPopoverPresentationTransitioningDelegate()
        popoverPresentationTransitioningDelegate?.sourceView = segment
        popoverPresentationTransitioningDelegate?.willDismissPopoverHandler = { _ in
            segment.selectedItems = []
        }
        controller.transitioningDelegate = popoverPresentationTransitioningDelegate
        controller.modalPresentationStyle = .custom
        present(controller, animated: true)
    }
}

// MARK: -

extension RootFilterViewController: FilterCellDelegate {
    func filterCell(_ filterCell: FilterCell, didTapRemoveSelectedValue selectionValue: SelectionWithTitle) {
        guard let indexPath = tableView.indexPath(for: filterCell), let filterInfo = filterInfo(at: indexPath) else {
            return
        }
        if filterInfo is ListSelectionFilterInfo || filterInfo is MultiLevelListSelectionFilterInfo {
            selectionDataSource.clearSelection(at: 0, in: selectionValue.selectionInfo)
        } else {
            selectionDataSource.clearAll(for: filterInfo)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension RootFilterViewController: SearchViewControllerDelegate {
    public func presentSearchViewController(_ searchViewController: SearchQueryViewController) {
        // Add view controller as child view controller
        addChild(searchViewController)
        view.addSubview(searchViewController.view)
        searchViewController.view.fillInSuperview()
        view.layoutIfNeeded()
        searchViewController.didMove(toParent: self)
    }

    public func searchViewController(_ searchViewController: SearchQueryViewController, didSelectQuery query: String?) {
        searchQueryCell.searchBar = searchViewController.searchBar
        guard let query = query, let searchQueryFilterInfo = self.filterInfo(at: IndexPath(row: 0, section: Section.searchQuery.rawValue)) else {
            return
        }
        selectionDataSource.setValue([query], for: searchQueryFilterInfo)
    }

    public func searchViewControllerDidCancelSearch(_ searchViewController: SearchQueryViewController) {
        searchQueryCell.searchBar = searchViewController.searchBar
        guard let searchQueryFilterInfo = self.filterInfo(at: IndexPath(row: 0, section: Section.searchQuery.rawValue)) else {
            return
        }
        selectionDataSource.clearAll(for: searchQueryFilterInfo)
    }
}

extension RootFilterViewController: VerticalListViewControllerDelegate {
    public func verticalListViewController(_: VerticalListViewController, didSelectVertical vertical: Vertical, at index: Int) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.filterRootViewController(self, didChangeVertical: vertical)
        }
    }
}

private extension RootFilterViewController {
    func setup() {
        view.backgroundColor = .milk
        view.addSubview(tableView)
        view.addSubview(showResultsButtonView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            showResultsButtonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            showResultsButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            showResultsButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            showResultsButtonView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
        ])
    }

    func filterInfo(at indexPath: IndexPath) -> FilterInfoType? {
        guard let section = Section(rawValue: indexPath.section) else {
            return nil
        }
        switch section {
        case .searchQuery:
            return filterDataSource.searchQuery
        case .preferences:
            return nil
        case .filters:
            return filterDataSource.filters[safe: indexPath.row]
        }
    }

    func selectionValuesForFilterComponent(at indexPath: IndexPath) -> [FilterSelectionInfo] {
        guard let filterInfo = self.filterInfo(at: indexPath) else {
            return []
        }
        return selectionDataSource.valueAndSubLevelValues(for: filterInfo)
    }

    func showResultsButtonViewTitle() -> String? {
        return String(format: "show_x_hits_button_title".localized(), filterDataSource.numberOfHits)
    }
}
